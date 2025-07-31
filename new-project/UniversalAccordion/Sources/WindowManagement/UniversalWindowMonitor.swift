import Foundation
import AppKit
import ApplicationServices

protocol UniversalWindowMonitorDelegate: AnyObject {
    func windowMonitor(_ monitor: UniversalWindowMonitor, didDetectWindows windows: [DocumentWindow])
    func windowMonitor(_ monitor: UniversalWindowMonitor, didDetectApplications applications: [Application])
    func windowMonitor(_ monitor: UniversalWindowMonitor, windowDidFocus window: DocumentWindow)
    func windowMonitor(_ monitor: UniversalWindowMonitor, windowDidClose windowID: CGWindowID)
}

class UniversalWindowMonitor: ObservableObject {
    weak var delegate: UniversalWindowMonitorDelegate?
    
    @Published var detectedWindows: [DocumentWindow] = []
    @Published var detectedApplications: [Application] = []
    @Published var applicationStates: [String: ApplicationState] = [:]
    
    private var monitoringTimer: Timer?
    private var isMonitoring = false
    private let refreshInterval: TimeInterval = Constants.WindowMonitoring.refreshInterval
    private weak var registryService: ApplicationRegistryService?
    
    init() {
        setupNotifications()
        setupRegistryServiceIntegration()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Interface
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        guard checkAccessibilityPermissions() else {
            DebugConsole.printAccessibilityPermissionRequired()
            return
        }
        
        isMonitoring = true
        refreshWindowList()
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.refreshWindowList()
        }
        
        DebugConsole.printMonitoringStarted()
    }
    
    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        DebugConsole.printMonitoringStopped()
    }
    
    func enableApplication(_ bundleID: String) {
        registryService?.enableApplication(bundleID)
        refreshWindowList()
    }
    
    func disableApplication(_ bundleID: String) {
        registryService?.disableApplication(bundleID)
        refreshWindowList()
    }
    
    func isApplicationEnabled(_ bundleID: String) -> Bool {
        return registryService?.isApplicationEnabled(bundleID) ?? false
    }
    
    var enabledApplications: Set<String> {
        return registryService?.enabledApplications ?? []
    }
    
    // MARK: - Window Detection
    
    private func refreshWindowList() {
        let allWindows = detectAllWindows()
        let allApps = detectRunningApplications()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.detectedWindows = allWindows
            self.detectedApplications = allApps
            
            self.delegate?.windowMonitor(self, didDetectWindows: allWindows)
            self.delegate?.windowMonitor(self, didDetectApplications: allApps)
        }
    }
    
    private func detectAllWindows() -> [DocumentWindow] {
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return []
        }
        
        var windows: [DocumentWindow] = []
        
        for windowInfo in windowList {
            guard let window = createDocumentWindow(from: windowInfo) else { continue }
            
            // Only include windows from enabled applications
            if enabledApplications.isEmpty || enabledApplications.contains(window.application.bundleIdentifier) {
                windows.append(window)
            }
        }
        
        return windows.sorted { $0.application.displayName < $1.application.displayName }
    }
    
    private func createDocumentWindow(from windowInfo: [String: Any]) -> DocumentWindow? {
        guard let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID,
              let ownerPID = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
              let boundsDict = windowInfo[kCGWindowBounds as String] as? [String: CGFloat] else {
            return nil
        }
        
        let title = windowInfo[kCGWindowName as String] as? String ?? ""
        let layer = windowInfo[kCGWindowLayer as String] as? Int ?? 0
        let isOnScreen = windowInfo[kCGWindowIsOnscreen as String] as? Bool ?? false
        
        // Skip system windows and windows without meaningful content
        if title.isEmpty && layer != 0 { return nil }
        if !isOnScreen { return nil }
        
        // Create bounds from dictionary
        let bounds = CGRect(
            x: boundsDict["X"] ?? 0,
            y: boundsDict["Y"] ?? 0,
            width: boundsDict["Width"] ?? 0,
            height: boundsDict["Height"] ?? 0
        )
        
        // Skip tiny windows (likely system elements)
        let minSize = Constants.WindowMonitoring.minimumWindowSize
        if bounds.width < minSize.width || bounds.height < minSize.height { return nil }
        
        // Get application info
        guard let application = getApplication(for: ownerPID) else { return nil }
        
        return DocumentWindow(
            windowID: windowID,
            title: title,
            application: application,
            bounds: bounds,
            isMinimized: false, // TODO: Detect minimized state
            isVisible: isOnScreen,
            layer: layer,
            ownerPID: ownerPID
        )
    }
    
    private func detectRunningApplications() -> [Application] {
        let runningApps = NSWorkspace.shared.runningApplications
        
        return runningApps.compactMap { app in
            guard let bundleID = app.bundleIdentifier,
                  let localizedName = app.localizedName else { return nil }
            
            // Skip system applications
            if bundleID.hasPrefix("com.apple.") && !shouldIncludeAppleApp(bundleID) { return nil }
            
            let icon = app.icon
            
            return Application(
                bundleIdentifier: bundleID,
                displayName: localizedName,
                icon: icon,
                processID: app.processIdentifier
            )
        }.sorted { $0.displayName < $1.displayName }
    }
    
    private func getApplication(for pid: pid_t) -> Application? {
        guard let runningApp = NSRunningApplication(processIdentifier: pid),
              let bundleID = runningApp.bundleIdentifier else {
            return Application.unknown
        }
        
        let displayName = runningApp.localizedName ?? bundleID
        let icon = runningApp.icon
        
        return Application(
            bundleIdentifier: bundleID,
            displayName: displayName,
            icon: icon,
            processID: pid
        )
    }
    
    private func shouldIncludeAppleApp(_ bundleID: String) -> Bool {
        return Constants.DefaultApplications.includedAppleApps.contains(bundleID)
    }
    
    // MARK: - Accessibility Permissions
    
    private func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        let workspace = NSWorkspace.shared
        let notificationCenter = workspace.notificationCenter
        
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidLaunch(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidTerminate(_:)),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidLaunch(_ notification: Notification) {
        if isMonitoring {
            // Delay to allow the application to fully launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.refreshWindowList()
            }
        }
    }
    
    @objc private func applicationDidTerminate(_ notification: Notification) {
        if isMonitoring {
            refreshWindowList()
        }
    }
    
    @objc private func applicationDidActivate(_ notification: Notification) {
        if isMonitoring {
            refreshWindowList()
        }
    }
    
    // MARK: - Registry Service Integration
    
    private func setupRegistryServiceIntegration() {
        registryService = ApplicationRegistryService.shared
        registryService?.delegate = self
        
        // Discover and register currently running applications
        registryService?.discoverAndRegisterApplications()
    }
}

// MARK: - ApplicationRegistryServiceDelegate

extension UniversalWindowMonitor: ApplicationRegistryServiceDelegate {
    func registryService(_ service: ApplicationRegistryService, didUpdateProfile profile: AppProfile) {
        // Refresh windows when profile is updated
        if isMonitoring {
            refreshWindowList()
        }
    }
    
    func registryService(_ service: ApplicationRegistryService, didRemoveProfile bundleIdentifier: String) {
        // Remove from application states
        applicationStates.removeValue(forKey: bundleIdentifier)
        
        if isMonitoring {
            refreshWindowList()
        }
    }
    
    func registryService(_ service: ApplicationRegistryService, didUpdateEnabledApplications applications: Set<String>) {
        // Update local application states
        for bundleIdentifier in applications {
            if applicationStates[bundleIdentifier] == nil {
                applicationStates[bundleIdentifier] = ApplicationState(bundleIdentifier: bundleIdentifier, isEnabled: true)
            } else {
                applicationStates[bundleIdentifier]?.isEnabled = true
            }
        }
        
        // Disable applications not in the enabled set
        for (bundleIdentifier, _) in applicationStates {
            if !applications.contains(bundleIdentifier) {
                applicationStates[bundleIdentifier]?.isEnabled = false
            }
        }
        
        if isMonitoring {
            refreshWindowList()
        }
    }
}