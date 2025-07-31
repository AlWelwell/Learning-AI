import Foundation

enum AccordionGroupingMode: String, CaseIterable {
    case byApp = "by_app"
    case byWorkspace = "by_workspace"
    case unified = "unified"
    case byProject = "by_project"
    
    var displayName: String {
        switch self {
        case .byApp:
            return "By Application"
        case .byWorkspace:
            return "By Workspace"
        case .unified:
            return "Unified View"
        case .byProject:
            return "By Project"
        }
    }
}

struct AccordionState {
    var groupingMode: AccordionGroupingMode = .byApp
    var expandedApplications: Set<String> = []
    var expandedWorkspaces: Set<String> = []
    var selectedWindowID: CGWindowID?
    var isVisible: Bool = false
    var animationDuration: Double = Constants.UI.animationDuration
    var autoCollapseOthers: Bool = true
    
    mutating func toggleApplication(_ bundleID: String) {
        if expandedApplications.contains(bundleID) {
            expandedApplications.remove(bundleID)
        } else {
            if autoCollapseOthers {
                expandedApplications.removeAll()
            }
            expandedApplications.insert(bundleID)
        }
    }
    
    mutating func toggleWorkspace(_ workspaceID: String) {
        if expandedWorkspaces.contains(workspaceID) {
            expandedWorkspaces.remove(workspaceID)
        } else {
            if autoCollapseOthers {
                expandedWorkspaces.removeAll()
            }
            expandedWorkspaces.insert(workspaceID)
        }
    }
    
    func isApplicationExpanded(_ bundleID: String) -> Bool {
        return expandedApplications.contains(bundleID)
    }
    
    func isWorkspaceExpanded(_ workspaceID: String) -> Bool {
        return expandedWorkspaces.contains(workspaceID)
    }
}