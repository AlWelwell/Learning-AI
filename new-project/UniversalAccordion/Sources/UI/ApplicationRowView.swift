import SwiftUI
import AppKit

struct ApplicationRowView: View {
    let application: Application
    let windows: [DocumentWindow]
    let isExpanded: Bool
    let profile: AppProfile?
    let onToggleExpanded: () -> Void
    let onWindowSelected: (DocumentWindow) -> Void
    let onToggleEnabled: () -> Void
    
    private var accentColor: Color {
        if let profile = profile {
            return Color(profile.accentColor)
        }
        return Color.accentColor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            applicationHeader
            
            if isExpanded {
                windowsList
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
    
    private var applicationHeader: View {
        HStack(spacing: 12) {
            // Application Icon
            Group {
                if let icon = application.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "app.dashed")
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 24, height: 24)
            
            // Application Info
            VStack(alignment: .leading, spacing: 2) {
                Text(application.displayName)
                    .font(.system(.body, design: .default, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(windows.count) window\(windows.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 8) {
                // Enable/Disable Toggle
                Button(action: onToggleEnabled) {
                    Image(systemName: profile?.isEnabled == true ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(profile?.isEnabled == true ? accentColor : .secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help(profile?.isEnabled == true ? "Disable monitoring" : "Enable monitoring")
                
                // Expand/Collapse Arrow
                Button(action: onToggleExpanded) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12, weight: .medium))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .buttonStyle(.plain)
                .disabled(windows.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if !windows.isEmpty {
                onToggleExpanded()
            }
        }
        .background(
            Rectangle()
                .foregroundColor(isExpanded ? accentColor.opacity(0.1) : Color.clear)
        )
    }
    
    private var windowsList: some View {
        VStack(spacing: 0) {
            ForEach(windows, id: \.windowID) { window in
                WindowRowView(
                    window: window,
                    accentColor: accentColor,
                    onSelected: { onWindowSelected(window) }
                )
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

struct WindowRowView: View {
    let window: DocumentWindow
    let accentColor: Color
    let onSelected: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Window Type Icon
            Image(systemName: windowTypeIcon)
                .foregroundColor(accentColor)
                .font(.system(size: 14))
                .frame(width: 16)
            
            // Window Info
            VStack(alignment: .leading, spacing: 2) {
                Text(window.title.isEmpty ? "Untitled Window" : window.title)
                    .font(.system(.body, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(windowDetailsText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Window State Indicators
            HStack(spacing: 4) {
                if !window.isVisible {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                if window.isMinimized {
                    Image(systemName: "minus.rectangle")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                // Focus Button
                Button(action: onSelected) {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(accentColor)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Focus window")
            }
        }
        .padding(.horizontal, 44) // Indent under app icon
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelected()
        }
        .background(
            Rectangle()
                .foregroundColor(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    private var windowTypeIcon: String {
        // Determine icon based on window properties
        if window.title.contains("Untitled") || window.title.isEmpty {
            return "doc"
        } else if window.title.contains("Settings") || window.title.contains("Preferences") {
            return "gearshape"
        } else if window.title.contains("Inspector") || window.title.contains("Properties") {
            return "sidebar.right"
        } else {
            return "doc.text"
        }
    }
    
    private var windowDetailsText: String {
        let width = Int(window.bounds.width)
        let height = Int(window.bounds.height)
        let position = "(\(Int(window.bounds.origin.x)), \(Int(window.bounds.origin.y)))"
        
        return "\(width) × \(height) at \(position)"
    }
}

#if DEBUG
struct ApplicationRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ApplicationRowView(
                application: Application(
                    bundleIdentifier: "com.microsoft.VSCode",
                    displayName: "Visual Studio Code",
                    icon: NSImage(systemSymbolName: "curlybraces.square", accessibilityDescription: nil),
                    processID: 12345
                ),
                windows: [
                    DocumentWindow(
                        windowID: 1,
                        title: "main.swift - UniversalAccordion",
                        application: Application(
                            bundleIdentifier: "com.microsoft.VSCode",
                            displayName: "Visual Studio Code",
                            icon: nil,
                            processID: 12345
                        ),
                        bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
                        isMinimized: false,
                        isVisible: true,
                        layer: 0,
                        ownerPID: 12345
                    ),
                    DocumentWindow(
                        windowID: 2,
                        title: "Settings",
                        application: Application(
                            bundleIdentifier: "com.microsoft.VSCode",
                            displayName: "Visual Studio Code",
                            icon: nil,
                            processID: 12345
                        ),
                        bounds: CGRect(x: 200, y: 150, width: 400, height: 300),
                        isMinimized: false,
                        isVisible: true,
                        layer: 0,
                        ownerPID: 12345
                    )
                ],
                isExpanded: true,
                profile: AppProfile(
                    bundleIdentifier: "com.microsoft.VSCode",
                    displayName: "Visual Studio Code",
                    accentColorHex: "#007ACC"
                ),
                onToggleExpanded: {},
                onWindowSelected: { _ in },
                onToggleEnabled: {}
            )
        }
        .frame(width: 350)
    }
}
#endif