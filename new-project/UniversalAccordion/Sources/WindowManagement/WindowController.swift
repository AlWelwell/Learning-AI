import Foundation
import AppKit
import ApplicationServices

class WindowController {
    
    // MARK: - Window Management
    
    static func focusWindow(_ window: DocumentWindow) -> Bool {
        // First, activate the application
        guard let runningApp = NSRunningApplication(processIdentifier: window.ownerPID) else {
            print("Failed to find running application for PID: \(window.ownerPID)")
            return false
        }
        
        let activated = runningApp.activate(options: [.activateIgnoringOtherApps])
        if !activated {
            print("Failed to activate application: \(window.application.displayName)")
            return false
        }
        
        // Try to focus the specific window using Accessibility API
        return focusWindowUsingAccessibility(window)
    }
    
    static func minimizeWindow(_ window: DocumentWindow) -> Bool {
        return performWindowAction(window, action: kAXMinimizeAction)
    }
    
    static func unminimizeWindow(_ window: DocumentWindow) -> Bool {
        // This is typically handled by focusing the window
        return focusWindow(window)
    }
    
    static func closeWindow(_ window: DocumentWindow) -> Bool {
        return performWindowAction(window, action: kAXCloseAction)
    }
    
    static func moveWindow(_ window: DocumentWindow, to position: CGPoint) -> Bool {
        guard let axWindow = getAccessibilityWindow(for: window) else { return false }
        
        let axPosition = AXValueCreate(AXValueType.cgPoint, &position.pointValue)
        let result = AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute, axPosition!)
        
        return result == .success
    }
    
    static func resizeWindow(_ window: DocumentWindow, to size: CGSize) -> Bool {
        guard let axWindow = getAccessibilityWindow(for: window) else { return false }
        
        let axSize = AXValueCreate(AXValueType.cgSize, &size.sizeValue)
        let result = AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute, axSize!)
        
        return result == .success
    }
    
    // MARK: - Window Information
    
    static func getWindowBounds(_ window: DocumentWindow) -> CGRect? {
        guard let axWindow = getAccessibilityWindow(for: window) else { return nil }
        
        var position: CFTypeRef?
        var size: CFTypeRef?
        
        let positionResult = AXUIElementCopyAttributeValue(axWindow, kAXPositionAttribute, &position)
        let sizeResult = AXUIElementCopyAttributeValue(axWindow, kAXSizeAttribute, &size)
        
        guard positionResult == .success,
              sizeResult == .success,
              let positionValue = position,
              let sizeValue = size else { return nil }
        
        var point = CGPoint.zero
        var cgSize = CGSize.zero
        
        let positionConverted = AXValueGetValue(positionValue as! AXValue, .cgPoint, &point)
        let sizeConverted = AXValueGetValue(sizeValue as! AXValue, .cgSize, &cgSize)
        
        guard positionConverted && sizeConverted else { return nil }
        
        return CGRect(origin: point, size: cgSize)
    }
    
    static func isWindowMinimized(_ window: DocumentWindow) -> Bool {
        guard let axWindow = getAccessibilityWindow(for: window) else { return false }
        
        var minimized: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(axWindow, kAXMinimizedAttribute, &minimized)
        
        guard result == .success,
              let minimizedValue = minimized as? Bool else { return false }
        
        return minimizedValue
    }
    
    // MARK: - Private Methods
    
    private static func focusWindowUsingAccessibility(_ window: DocumentWindow) -> Bool {
        guard let axWindow = getAccessibilityWindow(for: window) else { return false }
        
        // Try to perform the raise action first
        let raiseResult = AXUIElementPerformAction(axWindow, kAXRaiseAction)
        
        // Then try to set focus
        let focusResult = AXUIElementSetAttributeValue(axWindow, kAXFocusedAttribute, kCFBooleanTrue)
        
        return raiseResult == .success || focusResult == .success
    }
    
    private static func performWindowAction(_ window: DocumentWindow, action: CFString) -> Bool {
        guard let axWindow = getAccessibilityWindow(for: window) else { return false }
        
        let result = AXUIElementPerformAction(axWindow, action)
        return result == .success
    }
    
    private static func getAccessibilityWindow(for window: DocumentWindow) -> AXUIElement? {
        let app = AXUIElementCreateApplication(window.ownerPID)
        
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute, &windowsRef)
        
        guard result == .success,
              let windows = windowsRef as? [AXUIElement] else {
            return nil
        }
        
        // Find the matching window by title or position
        for axWindow in windows {
            if isMatchingWindow(axWindow, target: window) {
                return axWindow
            }
        }
        
        return nil
    }
    
    private static func isMatchingWindow(_ axWindow: AXUIElement, target: DocumentWindow) -> Bool {
        // Try to match by title first
        var titleRef: CFTypeRef?
        let titleResult = AXUIElementCopyAttributeValue(axWindow, kAXTitleAttribute, &titleRef)
        
        if titleResult == .success,
           let title = titleRef as? String,
           !title.isEmpty,
           title == target.title {
            return true
        }
        
        // If title doesn't match or is empty, try to match by position and size
        guard let bounds = getWindowBounds(from: axWindow) else { return false }
        
        let tolerance: CGFloat = 5.0
        return abs(bounds.origin.x - target.bounds.origin.x) < tolerance &&
               abs(bounds.origin.y - target.bounds.origin.y) < tolerance &&
               abs(bounds.size.width - target.bounds.size.width) < tolerance &&
               abs(bounds.size.height - target.bounds.size.height) < tolerance
    }
    
    private static func getWindowBounds(from axWindow: AXUIElement) -> CGRect? {
        var position: CFTypeRef?
        var size: CFTypeRef?
        
        let positionResult = AXUIElementCopyAttributeValue(axWindow, kAXPositionAttribute, &position)
        let sizeResult = AXUIElementCopyAttributeValue(axWindow, kAXSizeAttribute, &size)
        
        guard positionResult == .success,
              sizeResult == .success,
              let positionValue = position,
              let sizeValue = size else { return nil }
        
        var point = CGPoint.zero
        var cgSize = CGSize.zero
        
        let positionConverted = AXValueGetValue(positionValue as! AXValue, .cgPoint, &point)
        let sizeConverted = AXValueGetValue(sizeValue as! AXValue, .cgSize, &cgSize)
        
        guard positionConverted && sizeConverted else { return nil }
        
        return CGRect(origin: point, size: cgSize)
    }
}

// MARK: - Extensions

extension CGPoint {
    var pointValue: CGPoint { return self }
}

extension CGSize {
    var sizeValue: CGSize { return self }
}