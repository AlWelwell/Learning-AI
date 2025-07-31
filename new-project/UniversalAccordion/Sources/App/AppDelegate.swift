import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBar()
        requestAccessibilityPermissions()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up resources
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🪗"
        statusItem?.button?.toolTip = "Universal Window Accordion"
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Accordion", action: #selector(showAccordion), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            print("Accessibility permissions required for window management")
        }
    }
    
    @objc func showAccordion() {
        // TODO: Show accordion interface
        print("Show accordion requested")
    }
    
    @objc func showPreferences() {
        // TODO: Show preferences window
        print("Show preferences requested")
    }
}