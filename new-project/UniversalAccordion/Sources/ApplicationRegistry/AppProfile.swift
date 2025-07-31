import Foundation
import AppKit

struct KeyboardShortcut: Codable {
    let key: String
    let modifiers: [String]
    let action: String
    
    init(key: String, modifiers: [String], action: String) {
        self.key = key
        self.modifiers = modifiers
        self.action = action
    }
}

enum WindowBehavior: String, Codable, CaseIterable {
    case normal = "normal"
    case autoCollapse = "auto_collapse"
    case stayExpanded = "stay_expanded"
    case minimizeOthers = "minimize_others"
    
    var displayName: String {
        switch self {
        case .normal:
            return "Normal"
        case .autoCollapse:
            return "Auto Collapse Others"
        case .stayExpanded:
            return "Stay Expanded"
        case .minimizeOthers:
            return "Minimize Others"
        }
    }
}

struct AppProfile: Identifiable, Codable {
    var id: String { bundleIdentifier }
    let bundleIdentifier: String
    let displayName: String
    let accentColorHex: String
    let customShortcuts: [KeyboardShortcut]
    let windowBehavior: WindowBehavior
    let showPreviews: Bool
    let isEnabled: Bool
    let priority: Int
    
    init(
        bundleIdentifier: String,
        displayName: String,
        accentColorHex: String = "#007AFF",
        customShortcuts: [KeyboardShortcut] = [],
        windowBehavior: WindowBehavior = .normal,
        showPreviews: Bool = false,
        isEnabled: Bool = true,
        priority: Int = 0
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.accentColorHex = accentColorHex
        self.customShortcuts = customShortcuts
        self.windowBehavior = windowBehavior
        self.showPreviews = showPreviews
        self.isEnabled = isEnabled
        self.priority = priority
    }
}

extension AppProfile {
    var accentColor: NSColor {
        return NSColor(hex: accentColorHex) ?? NSColor.controlAccentColor
    }
    
    static let defaultProfiles: [AppProfile] = [
        AppProfile(
            bundleIdentifier: "com.microsoft.Word",
            displayName: "Microsoft Word",
            accentColorHex: "#2B579A",
            showPreviews: true
        ),
        AppProfile(
            bundleIdentifier: "com.adobe.Photoshop",
            displayName: "Adobe Photoshop",
            accentColorHex: "#31A8FF",
            showPreviews: true
        ),
        AppProfile(
            bundleIdentifier: "com.microsoft.VSCode",
            displayName: "Visual Studio Code",
            accentColorHex: "#007ACC"
        ),
        AppProfile(
            bundleIdentifier: "com.apple.Safari",
            displayName: "Safari",
            accentColorHex: "#007AFF"
        ),
        AppProfile(
            bundleIdentifier: "com.google.Chrome",
            displayName: "Google Chrome",
            accentColorHex: "#4285F4"
        )
    ]
}

extension NSColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        
        return nil
    }
}