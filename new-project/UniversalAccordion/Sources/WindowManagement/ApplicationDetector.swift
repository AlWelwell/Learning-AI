import Foundation
import AppKit

class ApplicationDetector {
    
    // MARK: - Application Detection
    
    static func getAllInstalledApplications() -> [Application] {
        var applications: [Application] = []
        
        // Get applications from /Applications
        applications.append(contentsOf: getApplicationsFromDirectory("/Applications"))
        
        // Get applications from ~/Applications
        if let userAppsPath = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first {
            applications.append(contentsOf: getApplicationsFromDirectory(userAppsPath))
        }
        
        // Get system applications from /System/Applications
        applications.append(contentsOf: getApplicationsFromDirectory("/System/Applications"))
        
        // Remove duplicates based on bundle identifier
        return removeDuplicateApplications(applications)
    }
    
    static func getRunningApplications() -> [Application] {
        let runningApps = NSWorkspace.shared.runningApplications
        
        return runningApps.compactMap { app in
            guard let bundleID = app.bundleIdentifier,
                  let localizedName = app.localizedName else { return nil }
            
            // Skip background processes and system services
            if app.activationPolicy == .prohibited || app.activationPolicy == .accessory {
                return nil
            }
            
            return Application(
                bundleIdentifier: bundleID,
                displayName: localizedName,
                icon: app.icon,
                processID: app.processIdentifier
            )
        }
    }
    
    static func detectApplicationForWindow(withPID pid: pid_t) -> Application? {
        guard let runningApp = NSRunningApplication(processIdentifier: pid),
              let bundleID = runningApp.bundleIdentifier else {
            return nil
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
    
    // MARK: - Application Information
    
    static func getApplicationInfo(bundleIdentifier: String) -> Application? {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier),
              let bundle = Bundle(url: appURL) else {
            return nil
        }
        
        let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                         bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                         bundleIdentifier
        
        let icon = NSWorkspace.shared.icon(forFile: appURL.path)
        
        return Application(
            bundleIdentifier: bundleIdentifier,
            displayName: displayName,
            icon: icon,
            processID: -1 // Not running
        )
    }
    
    static func getApplicationIcon(bundleIdentifier: String) -> NSImage? {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return nil
        }
        
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
    
    static func isApplicationRunning(bundleIdentifier: String) -> Bool {
        return NSWorkspace.shared.runningApplications.contains { app in
            app.bundleIdentifier == bundleIdentifier
        }
    }
    
    static func launchApplication(bundleIdentifier: String) -> Bool {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return false
        }
        
        do {
            try NSWorkspace.shared.launchApplication(at: appURL, options: [], configuration: [:])
            return true
        } catch {
            print("Failed to launch application \(bundleIdentifier): \(error)")
            return false
        }
    }
    
    // MARK: - Popular Applications
    
    static func getPopularApplications() -> [String] {
        return Constants.DefaultApplications.popular
    }
    
    // MARK: - Private Methods
    
    private static func getApplicationsFromDirectory(_ path: String) -> [Application] {
        let fileManager = FileManager.default
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var applications: [Application] = []
        
        for item in contents {
            if item.hasSuffix(".app") {
                let appPath = "\(path)/\(item)"
                if let application = createApplication(from: appPath) {
                    applications.append(application)
                }
            }
        }
        
        return applications
    }
    
    private static func createApplication(from path: String) -> Application? {
        guard let bundle = Bundle(path: path),
              let bundleID = bundle.bundleIdentifier else {
            return nil
        }
        
        let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                         bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                         URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
        
        let icon = NSWorkspace.shared.icon(forFile: path)
        
        return Application(
            bundleIdentifier: bundleID,
            displayName: displayName,
            icon: icon,
            processID: -1 // Not running
        )
    }
    
    private static func removeDuplicateApplications(_ applications: [Application]) -> [Application] {
        var uniqueApps: [String: Application] = [:]
        
        for app in applications {
            // Keep the first occurrence or prefer /Applications over other locations
            if uniqueApps[app.bundleIdentifier] == nil {
                uniqueApps[app.bundleIdentifier] = app
            }
        }
        
        return Array(uniqueApps.values).sorted { $0.displayName < $1.displayName }
    }
}