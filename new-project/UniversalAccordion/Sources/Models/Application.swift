import Foundation
import AppKit

struct Application: Identifiable, Equatable, Hashable {
    let id = UUID()
    let bundleIdentifier: String
    let displayName: String
    let icon: NSImage?
    let processID: pid_t
    let isEnabled: Bool
    
    init(bundleIdentifier: String, displayName: String, icon: NSImage? = nil, processID: pid_t, isEnabled: Bool = true) {
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.icon = icon
        self.processID = processID
        self.isEnabled = isEnabled
    }
    
    static func == (lhs: Application, rhs: Application) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier && lhs.processID == rhs.processID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
        hasher.combine(processID)
    }
}

extension Application {
    static let unknown = Application(
        bundleIdentifier: "unknown",
        displayName: "Unknown Application",
        icon: nil,
        processID: -1,
        isEnabled: false
    )
}