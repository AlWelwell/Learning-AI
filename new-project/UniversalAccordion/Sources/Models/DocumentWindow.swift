import Foundation
import AppKit

struct DocumentWindow: Identifiable, Equatable, Hashable {
    let id = UUID()
    let windowID: CGWindowID
    let title: String
    let application: Application
    let bounds: CGRect
    let isMinimized: Bool
    let isVisible: Bool
    let layer: Int
    let ownerPID: pid_t
    
    init(
        windowID: CGWindowID,
        title: String,
        application: Application,
        bounds: CGRect,
        isMinimized: Bool = false,
        isVisible: Bool = true,
        layer: Int = 0,
        ownerPID: pid_t
    ) {
        self.windowID = windowID
        self.title = title
        self.application = application
        self.bounds = bounds
        self.isMinimized = isMinimized
        self.isVisible = isVisible
        self.layer = layer
        self.ownerPID = ownerPID
    }
    
    static func == (lhs: DocumentWindow, rhs: DocumentWindow) -> Bool {
        return lhs.windowID == rhs.windowID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(windowID)
    }
}

extension DocumentWindow {
    var displayTitle: String {
        return title.isEmpty ? "Untitled" : title
    }
    
    var isMainWindow: Bool {
        return layer == 0 && isVisible && !isMinimized
    }
    
    func focus() -> Bool {
        let app = NSRunningApplication(processIdentifier: ownerPID)
        return app?.activate(options: [.activateIgnoringOtherApps]) ?? false
    }
}