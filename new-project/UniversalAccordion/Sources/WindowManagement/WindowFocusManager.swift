import Foundation
import AppKit
import ApplicationServices

class WindowFocusManager {
    
    static let shared = WindowFocusManager()
    
    private init() {}
    
    // MARK: - Window Focus Operations
    
    @discardableResult
    func focusWindow(_ window: DocumentWindow) -> Bool {
        guard checkAccessibilityPermissions() else {
            DebugConsole.printAccessibilityPermissionRequired()
            return false
        }
        
        // First, activate the application
        guard activateApplication(pid: window.ownerPID) else {
            print("Failed to activate application for PID: \(window.ownerPID)")
            return false
        }
        
        // Then focus the specific window
        return focusSpecificWindow(windowID: window.windowID, pid: window.ownerPID)
    }
    
    @discardableResult
    func activateApplication(pid: pid_t) -> Bool {
        guard let runningApp = NSRunningApplication(processIdentifier: pid) else {
            return false
        }
        
        return runningApp.activate(options: [.activateIgnoringOtherApps])
    }
    
    @discardableResult
    func activateApplication(bundleIdentifier: String) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        guard let app = runningApps.first(where: { $0.bundleIdentifier == bundleIdentifier }) else {
            return false
        }
        
        return app.activate(options: [.activateIgnoringOtherApps])
    }
    
    // MARK: - Advanced Window Operations
    
    @discardableResult
    func minimizeWindow(_ window: DocumentWindow) -> Bool {
        guard checkAccessibilityPermissions() else { return false }
        
        let app = AXUIElementCreateApplication(window.ownerPID)
        var windowElements: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValues(
            app,
            kAXWindowsAttribute as CFString,
            0,
            100,
            &windowElements
        )
        
        guard result == .success,
              let windows = windowElements as? [AXUIElement] else {
            return false
        }
        
        // Find the specific window
        for windowElement in windows {
            if let windowRef = getWindowID(from: windowElement),
               windowRef == window.windowID {
                
                // Minimize the window
                let minimizeResult = AXUIElementSetAttributeValue(
                    windowElement,
                    kAXMinimizedAttribute as CFString,
                    kCFBooleanTrue
                )
                
                return minimizeResult == .success
            }
        }
        
        return false
    }
    
    @discardableResult
    func closeWindow(_ window: DocumentWindow) -> Bool {
        guard checkAccessibilityPermissions() else { return false }
        
        let app = AXUIElementCreateApplication(window.ownerPID)
        var windowElements: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValues(
            app,
            kAXWindowsAttribute as CFString,
            0,
            100,
            &windowElements
        )
        
        guard result == .success,
              let windows = windowElements as? [AXUIElement] else {
            return false
        }
        
        // Find the specific window and close it
        for windowElement in windows {
            if let windowRef = getWindowID(from: windowElement),
               windowRef == window.windowID {
                
                // Try to get the close button
                var closeButton: CFTypeRef?
                let closeButtonResult = AXUIElementCopyAttributeValue(
                    windowElement,
                    kAXCloseButtonAttribute as CFString,
                    &closeButton
                )
                
                if closeButtonResult == .success,
                   let button = closeButton as AXUIElement? {
                    
                    let pressResult = AXUIElementPerformAction(
                        button,
                        kAXPressAction as CFString
                    )
                    
                    return pressResult == .success
                }
            }
        }
        
        return false
    }
    
    // MARK: - Window Information
    
    func getWindowBounds(_ window: DocumentWindow) -> CGRect? {
        guard checkAccessibilityPermissions() else { return nil }
        
        let app = AXUIElementCreateApplication(window.ownerPID)
        var windowElements: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValues(
            app,
            kAXWindowsAttribute as CFString,
            0,
            100,
            &windowElements
        )
        
        guard result == .success,
              let windows = windowElements as? [AXUIElement] else {
            return nil
        }
        
        for windowElement in windows {
            if let windowRef = getWindowID(from: windowElement),
               windowRef == window.windowID {
                
                var position: CFTypeRef?
                var size: CFTypeRef?
                
                let positionResult = AXUIElementCopyAttributeValue(
                    windowElement,
                    kAXPositionAttribute as CFString,
                    &position
                )
                
                let sizeResult = AXUIElementCopyAttributeValue(
                    windowElement,
                    kAXSizeAttribute as CFString,
                    &size
                )
                
                if positionResult == .success && sizeResult == .success,
                   let positionValue = position,
                   let sizeValue = size {
                    
                    var cgPosition = CGPoint.zero
                    var cgSize = CGSize.zero
                    
                    if AXValueGetValue(positionValue as! AXValue, .cgPoint, &cgPosition) &&
                       AXValueGetValue(sizeValue as! AXValue, .cgSize, &cgSize) {
                        return CGRect(origin: cgPosition, size: cgSize)
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func focusSpecificWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        let app = AXUIElementCreateApplication(pid)
        var windowElements: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValues(
            app,
            kAXWindowsAttribute as CFString,
            0,
            100,
            &windowElements
        )
        
        guard result == .success,
              let windows = windowElements as? [AXUIElement] else {
            print("Failed to get windows for PID: \(pid)")
            return false
        }
        
        // Find and focus the specific window
        for windowElement in windows {
            if let windowRef = getWindowID(from: windowElement),
               windowRef == windowID {
                
                // Raise the window to front
                let raiseResult = AXUIElementPerformAction(
                    windowElement,
                    kAXRaiseAction as CFString
                )
                
                // Also try to set it as the main window
                let mainResult = AXUIElementSetAttributeValue(
                    app,
                    kAXMainWindowAttribute as CFString,
                    windowElement
                )
                
                // And as the focused window
                let focusResult = AXUIElementSetAttributeValue(
                    app,
                    kAXFocusedWindowAttribute as CFString,
                    windowElement
                )
                
                print("Window focus results - Raise: \(raiseResult == .success), Main: \(mainResult == .success), Focus: \(focusResult == .success)")
                
                return raiseResult == .success || mainResult == .success || focusResult == .success
            }
        }
        
        print("Could not find window with ID: \(windowID)")
        return false
    }
    
    private func getWindowID(from windowElement: AXUIElement) -> CGWindowID? {
        var windowID: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            windowElement,
            kAXWindowIdAttribute as CFString,
            &windowID
        )
        
        guard result == .success,
              let windowIDValue = windowID else {
            return nil
        }
        
        var cgWindowID: CGWindowID = 0
        let success = CFNumberGetValue(
            windowIDValue as! CFNumber,
            .sInt32Type,
            &cgWindowID
        )
        
        return success ? cgWindowID : nil
    }
    
    private func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
}

// MARK: - Window Focus Convenience Extensions

extension DocumentWindow {
    @discardableResult
    func focus() -> Bool {
        return WindowFocusManager.shared.focusWindow(self)
    }
    
    @discardableResult
    func minimize() -> Bool {
        return WindowFocusManager.shared.minimizeWindow(self)
    }
    
    @discardableResult
    func close() -> Bool {
        return WindowFocusManager.shared.closeWindow(self)
    }
    
    func refreshBounds() -> CGRect? {
        return WindowFocusManager.shared.getWindowBounds(self)
    }
}