import Foundation

struct ApplicationState {
    let bundleIdentifier: String
    var isEnabled: Bool
    var priority: Int
    var lastUsed: Date?
    
    init(bundleIdentifier: String, isEnabled: Bool = false, priority: Int = 0) {
        self.bundleIdentifier = bundleIdentifier
        self.isEnabled = isEnabled
        self.priority = priority
        self.lastUsed = nil
    }
    
    mutating func markAsUsed() {
        lastUsed = Date()
    }
}

extension ApplicationState: Identifiable {
    var id: String { bundleIdentifier }
}

extension ApplicationState: Equatable {
    static func == (lhs: ApplicationState, rhs: ApplicationState) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}

extension ApplicationState: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }
}