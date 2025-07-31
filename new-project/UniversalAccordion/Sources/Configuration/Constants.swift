import Foundation

struct Constants {
    
    // MARK: - Window Monitoring
    
    struct WindowMonitoring {
        static let refreshInterval: TimeInterval = 2.0
        static let minimumWindowSize = CGSize(width: 50, height: 50)
        static let delayBeforeStartingMonitoring: TimeInterval = 1.0
    }
    
    // MARK: - Default Applications
    
    struct DefaultApplications {
        static let enabled = [
            "com.apple.Safari",
            "com.microsoft.VSCode", 
            "com.apple.finder",
            "com.apple.TextEdit",
            "com.google.Chrome"
        ]
        
        static let includedAppleApps = [
            "com.apple.Safari",
            "com.apple.finder",
            "com.apple.TextEdit",
            "com.apple.Preview",
            "com.apple.Notes",
            "com.apple.Pages",
            "com.apple.Numbers",
            "com.apple.Keynote",
            "com.apple.Xcode"
        ]
        
        static let popular = [
            // Browsers
            "com.google.Chrome",
            "com.apple.Safari",
            "org.mozilla.firefox",
            "com.microsoft.edgemac",
            
            // Development
            "com.microsoft.VSCode",
            "com.apple.Xcode",
            "com.jetbrains.intellij",
            "com.github.GitHubDesktop",
            "com.sublimetext.4",
            
            // Design
            "com.adobe.Photoshop",
            "com.adobe.Illustrator",
            "com.figma.Desktop",
            "com.sketchapp.SketchMirror",
            
            // Office
            "com.microsoft.Word",
            "com.microsoft.Excel",
            "com.microsoft.PowerPoint",
            "com.apple.Pages",
            "com.apple.Numbers",
            "com.apple.Keynote",
            
            // Communication
            "com.tinyspeck.slackmacgap",
            "us.zoom.xos",
            "com.microsoft.teams2",
            "com.discord.Discord",
            
            // Media
            "com.spotify.client",
            "tv.plex.plexmediaplayer",
            "com.apple.QuickTimePlayerX",
            
            // Utilities
            "com.apple.finder",
            "com.apple.Terminal",
            "com.apple.TextEdit",
            "com.apple.Preview"
        ]
    }
    
    // MARK: - UI Configuration
    
    struct UI {
        static let menuBarTitle = "🪗"
        static let menuBarToolTip = "Universal Window Accordion"
        static let animationDuration: Double = 0.3
        static let defaultAccentColor = "#007AFF"
    }
    
    // MARK: - System Preferences URLs
    
    struct SystemPreferences {
        static let accessibilityPrivacy = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    }
    
    // MARK: - Error Messages
    
    struct ErrorMessages {
        static let noAccessibilityPermissions = "Accessibility permissions required for window management"
        static let noWindowMonitorAvailable = "No window monitor available"
        static let failedToActivateApplication = "Failed to activate application"
        static let failedToFindRunningApplication = "Failed to find running application for PID"
    }
    
    // MARK: - User Defaults Keys
    
    struct UserDefaults {
        static let enabledApplicationsKey = "enabledApplications"
        static let profilesKey = "applicationProfiles"
        static let windowMonitoringInterval = "windowMonitoringInterval"
        static let accordionGroupingMode = "accordionGroupingMode"
        static let autoCollapseOthers = "autoCollapseOthers"
    }
}