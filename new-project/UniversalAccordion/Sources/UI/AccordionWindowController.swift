import Cocoa
import SwiftUI

class AccordionWindowController: NSWindowController {
    
    private weak var windowMonitor: UniversalWindowMonitor?
    
    init(windowMonitor: UniversalWindowMonitor) {
        self.windowMonitor = windowMonitor
        
        // Create the window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        setupWindow()
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWindow() {
        guard let window = window else { return }
        
        window.title = "Universal Window Accordion"
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        
        // Center the window
        window.center()
        
        // Set minimum size
        window.minSize = NSSize(width: 800, height: 600)
        
        // Configure window appearance
        window.backgroundColor = NSColor.windowBackgroundColor
        
        // Make window appear in front
        window.level = .normal
        
        // Configure close behavior
        window.isReleasedWhenClosed = false
    }
    
    private func setupContent() {
        guard let window = window, let monitor = windowMonitor else { return }
        
        // Create the SwiftUI view
        let accordionView = AccordionView(windowMonitor: monitor)
        
        // Wrap in hosting view
        let hostingView = NSHostingView(rootView: accordionView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set as window content
        window.contentView = hostingView
    }
    
    // MARK: - Public Interface
    
    func showWindow() {
        guard let window = window else { return }
        
        if !window.isVisible {
            window.makeKeyAndOrderFront(nil)
        } else {
            window.orderFront(nil)
        }
        
        // Bring to current space
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideWindow() {
        window?.orderOut(nil)
    }
    
    func toggleWindow() {
        guard let window = window else { return }
        
        if window.isVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }
}

// MARK: - NSWindowDelegate

extension AccordionWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Don't terminate the app when accordion window closes
        // Just hide it instead
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        // Window became active
    }
    
    func windowDidResignKey(_ notification: Notification) {
        // Window lost focus
    }
}