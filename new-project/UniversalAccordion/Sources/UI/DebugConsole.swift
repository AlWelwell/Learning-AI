import Foundation

class DebugConsole {
    
    static func printDetectedWindows(_ windows: [DocumentWindow]) {
        print("\n=== Detected Windows (\(windows.count)) ===")
        for window in windows {
            print("📱 \(window.application.displayName): \(window.displayTitle)")
            print("   ID: \(window.windowID), PID: \(window.ownerPID)")
            print("   Bounds: \(window.bounds)")
            print("   Visible: \(window.isVisible), Layer: \(window.layer)")
            print("")
        }
    }
    
    static func printRunningApplications(_ applications: [Application], states: [String: ApplicationState] = [:]) {
        print("\n=== Running Applications (\(applications.count)) ===")
        for app in applications {
            let isEnabled = states[app.bundleIdentifier]?.isEnabled ?? false
            let enabledStatus = isEnabled ? "✅" : "❌"
            print("\(enabledStatus) \(app.displayName) (\(app.bundleIdentifier))")
            print("   PID: \(app.processID)")
        }
        print("")
    }
    
    static func printWindowMonitorStatus(windowCount: Int, appCount: Int) {
        print("🔍 Window Monitor Status:")
        print("   Detected \(windowCount) windows from \(appCount) applications")
    }
    
    static func printWindowDetectionEvent(windows: [DocumentWindow]) {
        print("🔍 Detected \(windows.count) windows")
    }
    
    static func printApplicationDetectionEvent(applications: [Application]) {
        print("🔍 Detected \(applications.count) applications")
    }
    
    static func printWindowFocusEvent(_ window: DocumentWindow) {
        print("🎯 Window focused: \(window.displayTitle) (\(window.application.displayName))")
    }
    
    static func printWindowCloseEvent(windowID: CGWindowID) {
        print("❌ Window closed: \(windowID)")
    }
    
    static func printMonitoringStarted() {
        print("✅ Universal window monitoring started")
    }
    
    static func printMonitoringStopped() {
        print("⏹️ Universal window monitoring stopped")
    }
    
    static func printAccessibilityPermissionRequired() {
        print("⚠️ Accessibility permissions required for window management") 
    }
    
    static func printAccessibilityPermissionGranted() {
        print("✅ Accessibility permissions granted, starting monitoring")
    }
}