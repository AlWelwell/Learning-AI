import Foundation

struct WorkspaceConfiguration: Identifiable, Codable {
    let id = UUID()
    let name: String
    let applications: [String] // Bundle identifiers
    let createdAt: Date
    var lastUsed: Date
    var isActive: Bool
    
    init(name: String, applications: [String] = [], isActive: Bool = false) {
        self.name = name
        self.applications = applications
        self.createdAt = Date()
        self.lastUsed = Date()
        self.isActive = isActive
    }
}

struct AppGroup: Identifiable {
    let id = UUID()
    let application: Application
    let windows: [DocumentWindow]
    let isExpanded: Bool
    
    var windowCount: Int {
        return windows.count
    }
    
    var mainWindow: DocumentWindow? {
        return windows.first { $0.isMainWindow }
    }
    
    var visibleWindows: [DocumentWindow] {
        return windows.filter { $0.isVisible && !$0.isMinimized }
    }
}

struct WindowGroup: Identifiable {
    let id = UUID()
    let name: String
    let windows: [DocumentWindow]
    let applications: Set<Application>
    let groupType: GroupType
    
    enum GroupType {
        case application(Application)
        case workspace(WorkspaceConfiguration)
        case project(String)
        case custom(String)
    }
    
    var primaryApplication: Application? {
        switch groupType {
        case .application(let app):
            return app
        case .workspace, .project, .custom:
            return applications.first
        }
    }
}