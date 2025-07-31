import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var menuBarManager: MenuBarManager?
    private var windowMonitor: UniversalWindowMonitor?
    private var accordionWindowController: AccordionWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBar()
        setupWindowMonitoring()
        requestAccessibilityPermissions()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        windowMonitor?.stopMonitoring()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func setupMenuBar() {
        menuBarManager = MenuBarManager()
        menuBarManager?.delegate = self
    }
    
    private func setupWindowMonitoring() {
        windowMonitor = UniversalWindowMonitor()
        windowMonitor?.delegate = self
        
        // Create accordion window controller
        if let monitor = windowMonitor {
            accordionWindowController = AccordionWindowController(windowMonitor: monitor)
        }
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            DebugConsole.printAccessibilityPermissionRequired()
            showAccessibilityAlert()
        } else {
            // Start monitoring after a short delay to ensure setup is complete
            DebugConsole.printAccessibilityPermissionGranted()
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.WindowMonitoring.delayBeforeStartingMonitoring) {
                self.windowMonitor?.startMonitoring()
            }
        }
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "Universal Window Accordion needs accessibility permissions to detect and manage windows from other applications. Please grant permission in System Preferences > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: Constants.SystemPreferences.accessibilityPrivacy)!)
        }
    }
}

// MARK: - MenuBarManagerDelegate

extension AppDelegate: MenuBarManagerDelegate {
    func menuBarManager(_ manager: MenuBarManager, didRequestShowAccordion: Void) {
        accordionWindowController?.showWindow()
    }
    
    func menuBarManager(_ manager: MenuBarManager, didRequestStartMonitoring: Void) {
        windowMonitor?.startMonitoring()
    }
    
    func menuBarManager(_ manager: MenuBarManager, didRequestStopMonitoring: Void) {
        windowMonitor?.stopMonitoring()
    }
    
    func menuBarManager(_ manager: MenuBarManager, didRequestShowDetectedWindows: Void) {
        guard let windows = windowMonitor?.detectedWindows else {
            print("No window monitor available")
            return
        }
        DebugConsole.printDetectedWindows(windows)
    }
    
    func menuBarManager(_ manager: MenuBarManager, didRequestShowRunningApps: Void) {
        guard let apps = windowMonitor?.detectedApplications,
              let states = windowMonitor?.applicationStates else {
            print("No window monitor available")
            return
        }
        DebugConsole.printRunningApplications(apps, states: states)
    }
    
    func menuBarManager(_ manager: MenuBarManager, didRequestShowPreferences: Void) {
        // TODO: Show preferences window
        print("Show preferences requested")
    }
}

// MARK: - UniversalWindowMonitorDelegate

extension AppDelegate: UniversalWindowMonitorDelegate {
    func windowMonitor(_ monitor: UniversalWindowMonitor, didDetectWindows windows: [DocumentWindow]) {
        DebugConsole.printWindowDetectionEvent(windows: windows)
    }
    
    func windowMonitor(_ monitor: UniversalWindowMonitor, didDetectApplications applications: [Application]) {
        DebugConsole.printApplicationDetectionEvent(applications: applications)
    }
    
    func windowMonitor(_ monitor: UniversalWindowMonitor, windowDidFocus window: DocumentWindow) {
        DebugConsole.printWindowFocusEvent(window)
    }
    
    func windowMonitor(_ monitor: UniversalWindowMonitor, windowDidClose windowID: CGWindowID) {
        DebugConsole.printWindowCloseEvent(windowID: windowID)
    }
}