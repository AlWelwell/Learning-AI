import Foundation
import AppKit

struct Application: Identifiable, Equatable, Hashable {
    // Use bundle identifier as stable ID instead of random UUID
    var id: String { bundleIdentifier }
    
    let bundleIdentifier: String
    let displayName: String
    let icon: NSImage?
    let processID: pid_t
    
    init(bundleIdentifier: String, displayName: String, icon: NSImage? = nil, processID: pid_t) {
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.icon = icon
        self.processID = processID
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
        processID: -1
    )
}