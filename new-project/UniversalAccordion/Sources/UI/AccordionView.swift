import SwiftUI
import AppKit

struct AccordionView: View {
    @ObservedObject var windowMonitor: UniversalWindowMonitor
    @ObservedObject var registryService = ApplicationRegistryService.shared
    @State private var accordionState = AccordionState()
    
    var body: some View {
        NavigationView {
            sidebar
            mainContent
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            sidebarHeader
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedApplications, id: \.bundleIdentifier) { app in
                        ApplicationRowView(
                            application: app,
                            windows: windowsForApplication(app.bundleIdentifier),
                            isExpanded: accordionState.isApplicationExpanded(app.bundleIdentifier),
                            profile: registryService.getProfile(for: app.bundleIdentifier),
                            onToggleExpanded: {
                                withAnimation(.easeInOut(duration: accordionState.animationDuration)) {
                                    accordionState.toggleApplication(app.bundleIdentifier)
                                }
                            },
                            onWindowSelected: { window in
                                accordionState.selectedWindowID = window.windowID
                                focusWindow(window)
                            },
                            onToggleEnabled: {
                                registryService.toggleApplication(app.bundleIdentifier)
                            }
                        )
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 300, maxWidth: 400)
    }
    
    private var sidebarHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Applications")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Menu {
                    Button("Refresh") {
                        windowMonitor.startMonitoring()
                    }
                    
                    Divider()
                    
                    Button("Enable All") {
                        for app in windowMonitor.detectedApplications {
                            registryService.enableApplication(app.bundleIdentifier)
                        }
                    }
                    
                    Button("Disable All") {
                        registryService.disableAllApplications()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
            }
            
            GroupingModeSelector(
                selectedMode: $accordionState.groupingMode
            )
            
            statsView
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
    
    private var statsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(windowMonitor.detectedApplications.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(windowMonitor.detectedWindows.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Windows")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(registryService.enabledApplications.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Enabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private var mainContent: some View {
        Group {
            if let selectedWindowID = accordionState.selectedWindowID,
               let selectedWindow = windowMonitor.detectedWindows.first(where: { $0.windowID == selectedWindowID }) {
                WindowDetailView(window: selectedWindow)
            } else {
                EmptySelectionView()
            }
        }
    }
    
    // MARK: - Data Processing
    
    private var groupedApplications: [Application] {
        switch accordionState.groupingMode {
        case .byApp:
            return windowMonitor.detectedApplications
                .filter { app in
                    registryService.isApplicationEnabled(app.bundleIdentifier) &&
                    !windowsForApplication(app.bundleIdentifier).isEmpty
                }
                .sorted { app1, app2 in
                    let profile1 = registryService.getProfile(for: app1.bundleIdentifier)
                    let profile2 = registryService.getProfile(for: app2.bundleIdentifier)
                    
                    // Sort by priority first, then by name
                    if let p1 = profile1, let p2 = profile2 {
                        if p1.priority != p2.priority {
                            return p1.priority > p2.priority
                        }
                    }
                    return app1.displayName < app2.displayName
                }
        case .byWorkspace, .unified, .byProject:
            // TODO: Implement other grouping modes
            return windowMonitor.detectedApplications
                .filter { registryService.isApplicationEnabled($0.bundleIdentifier) }
                .sorted { $0.displayName < $1.displayName }
        }
    }
    
    private func windowsForApplication(_ bundleIdentifier: String) -> [DocumentWindow] {
        return windowMonitor.detectedWindows
            .filter { $0.application.bundleIdentifier == bundleIdentifier }
            .sorted { $0.title < $1.title }
    }
    
    // MARK: - Actions
    
    private func focusWindow(_ window: DocumentWindow) {
        // Focus the window using Accessibility API
        let windowID = window.windowID
        
        // First, activate the application
        if let runningApp = NSRunningApplication(processIdentifier: window.ownerPID) {
            runningApp.activate(options: [.activateIgnoringOtherApps])
        }
        
        // Then try to focus the specific window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This would require more advanced window management
            // For now, just activating the application
            print("Focused window: \(window.title) in \(window.application.displayName)")
        }
    }
}

struct GroupingModeSelector: View {
    @Binding var selectedMode: AccordionGroupingMode
    
    var body: some View {
        Picker("Grouping", selection: $selectedMode) {
            ForEach(AccordionGroupingMode.allCases, id: \.self) { mode in
                Text(mode.displayName)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}

struct EmptySelectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "macwindow")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Window Selected")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Select a window from the sidebar to see its details")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }
}

#if DEBUG
struct AccordionView_Previews: PreviewProvider {
    static var previews: some View {
        let monitor = UniversalWindowMonitor()
        AccordionView(windowMonitor: monitor)
    }
}
#endif