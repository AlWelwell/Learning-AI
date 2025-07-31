import SwiftUI
import AppKit

struct WindowDetailView: View {
    let window: DocumentWindow
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                propertiesSection
                boundsSection
                actionsSection
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(NSColor.textBackgroundColor))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Application Icon
                Group {
                    if let icon = window.application.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "app.dashed")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(window.title.isEmpty ? "Untitled Window" : window.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(window.application.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Window Status Badges
            HStack(spacing: 8) {
                StatusBadge(
                    text: window.isVisible ? "Visible" : "Hidden",
                    color: window.isVisible ? .green : .orange,
                    systemImage: window.isVisible ? "eye" : "eye.slash"
                )
                
                if window.isMinimized {
                    StatusBadge(
                        text: "Minimized",
                        color: .blue,
                        systemImage: "minus.rectangle"
                    )
                }
                
                StatusBadge(
                    text: "Layer \(window.layer)",
                    color: .gray,
                    systemImage: "square.stack"
                )
            }
        }
    }
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Properties", systemImage: "list.bullet.rectangle")
            
            VStack(spacing: 12) {
                PropertyRow(label: "Window ID", value: "\(window.windowID)")
                PropertyRow(label: "Process ID", value: "\(window.ownerPID)")
                PropertyRow(label: "Bundle ID", value: window.application.bundleIdentifier)
                PropertyRow(label: "Layer", value: "\(window.layer)")
            }
        }
    }
    
    private var boundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Bounds & Position", systemImage: "rectangle.inset.filled")
            
            VStack(spacing: 12) {
                PropertyRow(label: "Width", value: "\(Int(window.bounds.width)) px")
                PropertyRow(label: "Height", value: "\(Int(window.bounds.height)) px")
                PropertyRow(label: "X Position", value: "\(Int(window.bounds.origin.x)) px")
                PropertyRow(label: "Y Position", value: "\(Int(window.bounds.origin.y)) px")
            }
            
            // Visual bounds representation
            BoundsVisualization(bounds: window.bounds)
        }
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Actions", systemImage: "hand.tap")
            
            VStack(spacing: 12) {
                ActionButton(
                    title: "Focus Window",
                    subtitle: "Bring this window to the front",
                    systemImage: "arrow.up.right.square",
                    color: .blue
                ) {
                    focusWindow()
                }
                
                ActionButton(
                    title: "Show in Finder",
                    subtitle: "Reveal the application in Finder",
                    systemImage: "folder",
                    color: .orange
                ) {
                    showInFinder()
                }
                
                ActionButton(
                    title: "Quit Application",
                    subtitle: "Terminate the application",
                    systemImage: "xmark.circle",
                    color: .red
                ) {
                    quitApplication()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func focusWindow() {
        if let runningApp = NSRunningApplication(processIdentifier: window.ownerPID) {
            runningApp.activate(options: [.activateIgnoringOtherApps])
        }
    }
    
    private func showInFinder() {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: window.application.bundleIdentifier) {
            NSWorkspace.shared.activateFileViewerSelecting([appURL])
        }
    }
    
    private func quitApplication() {
        if let runningApp = NSRunningApplication(processIdentifier: window.ownerPID) {
            runningApp.terminate()
        }
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundColor(.accentColor)
                .font(.system(size: 16, weight: .medium))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct PropertyRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .textSelection(.enabled)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(6)
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.tertiary)
                    .font(.caption)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct BoundsVisualization: View {
    let bounds: CGRect
    
    private var screenBounds: CGRect {
        NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
    }
    
    private var scale: CGFloat {
        let availableWidth: CGFloat = 300
        let availableHeight: CGFloat = 200
        
        let scaleX = availableWidth / screenBounds.width
        let scaleY = availableHeight / screenBounds.height
        
        return min(scaleX, scaleY, 0.3) // Cap at 30% scale
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visual Position")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack {
                // Screen background
                Rectangle()
                    .stroke(Color.secondary, lineWidth: 1)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                    .frame(
                        width: screenBounds.width * scale,
                        height: screenBounds.height * scale
                    )
                
                // Window rectangle
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .stroke(Color.accentColor, lineWidth: 2)
                    .frame(
                        width: bounds.width * scale,
                        height: bounds.height * scale
                    )
                    .offset(
                        x: (bounds.origin.x - screenBounds.width/2) * scale,
                        y: (screenBounds.height/2 - bounds.origin.y - bounds.height) * scale
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
        }
    }
}

#if DEBUG
struct WindowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WindowDetailView(
            window: DocumentWindow(
                windowID: 12345,
                title: "main.swift - UniversalAccordion",
                application: Application(
                    bundleIdentifier: "com.microsoft.VSCode",
                    displayName: "Visual Studio Code",
                    icon: NSImage(systemSymbolName: "curlybraces.square", accessibilityDescription: nil),
                    processID: 67890
                ),
                bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
                isMinimized: false,
                isVisible: true,
                layer: 0,
                ownerPID: 67890
            )
        )
        .frame(width: 400, height: 600)
    }
}
#endif