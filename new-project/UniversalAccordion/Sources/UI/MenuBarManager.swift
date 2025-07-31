import Cocoa

protocol MenuBarManagerDelegate: AnyObject {
    func menuBarManager(_ manager: MenuBarManager, didRequestShowAccordion: Void)
    func menuBarManager(_ manager: MenuBarManager, didRequestStartMonitoring: Void)
    func menuBarManager(_ manager: MenuBarManager, didRequestStopMonitoring: Void)
    func menuBarManager(_ manager: MenuBarManager, didRequestShowDetectedWindows: Void)
    func menuBarManager(_ manager: MenuBarManager, didRequestShowRunningApps: Void)
    func menuBarManager(_ manager: MenuBarManager, didRequestShowPreferences: Void)
}

class MenuBarManager {
    weak var delegate: MenuBarManagerDelegate?
    
    private var statusItem: NSStatusItem?
    
    init() {
        setupMenuBar()
    }
    
    func updateTitle(_ title: String) {
        statusItem?.button?.title = title
    }
    
    func updateToolTip(_ toolTip: String) {
        statusItem?.button?.toolTip = toolTip
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = Constants.UI.menuBarTitle
        statusItem?.button?.toolTip = Constants.UI.menuBarToolTip
        
        let menu = createMainMenu()
        statusItem?.menu = menu
    }
    
    private func createMainMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Main actions
        menu.addItem(createMenuItem(
            title: "Show Accordion",
            action: #selector(showAccordion),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        
        // Monitoring controls
        menu.addItem(createMenuItem(
            title: "Start Monitoring",
            action: #selector(startMonitoring),
            keyEquivalent: ""
        ))
        menu.addItem(createMenuItem(
            title: "Stop Monitoring",
            action: #selector(stopMonitoring),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        
        // Debug submenu
        let debugMenuItem = NSMenuItem(title: "Debug", action: nil, keyEquivalent: "")
        debugMenuItem.submenu = createDebugMenu()
        menu.addItem(debugMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        // Settings and quit
        menu.addItem(createMenuItem(
            title: "Preferences",
            action: #selector(showPreferences),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        ))
        
        return menu
    }
    
    private func createDebugMenu() -> NSMenu {
        let debugMenu = NSMenu()
        
        debugMenu.addItem(createMenuItem(
            title: "Show Detected Windows",
            action: #selector(showDetectedWindows),
            keyEquivalent: ""
        ))
        debugMenu.addItem(createMenuItem(
            title: "Show Running Apps",
            action: #selector(showRunningApps),
            keyEquivalent: ""
        ))
        
        return debugMenu
    }
    
    private func createMenuItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        return item
    }
    
    // MARK: - Menu Actions
    
    @objc private func showAccordion() {
        delegate?.menuBarManager(self, didRequestShowAccordion: ())
    }
    
    @objc private func startMonitoring() {
        delegate?.menuBarManager(self, didRequestStartMonitoring: ())
    }
    
    @objc private func stopMonitoring() {
        delegate?.menuBarManager(self, didRequestStopMonitoring: ())
    }
    
    @objc private func showDetectedWindows() {
        delegate?.menuBarManager(self, didRequestShowDetectedWindows: ())
    }
    
    @objc private func showRunningApps() {
        delegate?.menuBarManager(self, didRequestShowRunningApps: ())
    }
    
    @objc private func showPreferences() {
        delegate?.menuBarManager(self, didRequestShowPreferences: ())
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}