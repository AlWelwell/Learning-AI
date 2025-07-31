import Foundation
import AppKit

protocol ApplicationRegistryServiceDelegate: AnyObject {
    func registryService(_ service: ApplicationRegistryService, didUpdateProfile profile: AppProfile)
    func registryService(_ service: ApplicationRegistryService, didRemoveProfile bundleIdentifier: String)
    func registryService(_ service: ApplicationRegistryService, didUpdateEnabledApplications applications: Set<String>)
}

class ApplicationRegistryService: ObservableObject {
    static let shared = ApplicationRegistryService()
    
    weak var delegate: ApplicationRegistryServiceDelegate?
    
    @Published private(set) var profiles: [String: AppProfile] = [:]
    @Published private(set) var enabledApplications: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let profilesKey = Constants.UserDefaults.profilesKey
    private let enabledAppsKey = Constants.UserDefaults.enabledApplicationsKey
    
    private init() {
        loadProfiles()
        loadEnabledApplications()
        setupDefaultProfiles()
    }
    
    // MARK: - Profile Management
    
    func getProfile(for bundleIdentifier: String) -> AppProfile? {
        return profiles[bundleIdentifier]
    }
    
    func getAllProfiles() -> [AppProfile] {
        return Array(profiles.values).sorted { $0.priority > $1.priority }
    }
    
    func getEnabledProfiles() -> [AppProfile] {
        return profiles.values.filter { $0.isEnabled }.sorted { $0.priority > $1.priority }
    }
    
    func addProfile(_ profile: AppProfile) {
        profiles[profile.bundleIdentifier] = profile
        saveProfiles()
        delegate?.registryService(self, didUpdateProfile: profile)
    }
    
    func updateProfile(_ profile: AppProfile) {
        profiles[profile.bundleIdentifier] = profile
        saveProfiles()
        
        // Update enabled applications set if profile enabled state changed
        if profile.isEnabled {
            enabledApplications.insert(profile.bundleIdentifier)
        } else {
            enabledApplications.remove(profile.bundleIdentifier)
        }
        saveEnabledApplications()
        
        delegate?.registryService(self, didUpdateProfile: profile)
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    func removeProfile(bundleIdentifier: String) {
        profiles.removeValue(forKey: bundleIdentifier)
        enabledApplications.remove(bundleIdentifier)
        
        saveProfiles()
        saveEnabledApplications()
        
        delegate?.registryService(self, didRemoveProfile: bundleIdentifier)
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    func createProfileForApplication(_ application: Application) -> AppProfile {
        // Check if we have a default profile for this app
        if let defaultProfile = AppProfile.defaultProfiles.first(where: { $0.bundleIdentifier == application.bundleIdentifier }) {
            return defaultProfile
        }
        
        // Create a basic profile
        return AppProfile(
            bundleIdentifier: application.bundleIdentifier,
            displayName: application.displayName,
            accentColorHex: Constants.UI.defaultAccentColor,
            isEnabled: Constants.DefaultApplications.enabled.contains(application.bundleIdentifier)
        )
    }
    
    // MARK: - Application Enable/Disable
    
    func enableApplication(_ bundleIdentifier: String) {
        enabledApplications.insert(bundleIdentifier)
        
        // Update or create profile
        if var profile = profiles[bundleIdentifier] {
            let updatedProfile = AppProfile(
                bundleIdentifier: profile.bundleIdentifier,
                displayName: profile.displayName,
                accentColorHex: profile.accentColorHex,
                customShortcuts: profile.customShortcuts,
                windowBehavior: profile.windowBehavior,
                showPreviews: profile.showPreviews,
                isEnabled: true,
                priority: profile.priority
            )
            profiles[bundleIdentifier] = updatedProfile
        }
        
        saveEnabledApplications()
        saveProfiles()
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    func disableApplication(_ bundleIdentifier: String) {
        enabledApplications.remove(bundleIdentifier)
        
        // Update profile if it exists
        if var profile = profiles[bundleIdentifier] {
            let updatedProfile = AppProfile(
                bundleIdentifier: profile.bundleIdentifier,
                displayName: profile.displayName,
                accentColorHex: profile.accentColorHex,
                customShortcuts: profile.customShortcuts,
                windowBehavior: profile.windowBehavior,
                showPreviews: profile.showPreviews,
                isEnabled: false,
                priority: profile.priority
            )
            profiles[bundleIdentifier] = updatedProfile
        }
        
        saveEnabledApplications()
        saveProfiles()
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    func isApplicationEnabled(_ bundleIdentifier: String) -> Bool {
        return enabledApplications.contains(bundleIdentifier)
    }
    
    func toggleApplication(_ bundleIdentifier: String) {
        if isApplicationEnabled(bundleIdentifier) {
            disableApplication(bundleIdentifier)
        } else {
            enableApplication(bundleIdentifier)
        }
    }
    
    // MARK: - Bulk Operations
    
    func enableMultipleApplications(_ bundleIdentifiers: [String]) {
        for bundleIdentifier in bundleIdentifiers {
            enabledApplications.insert(bundleIdentifier)
        }
        saveEnabledApplications()
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    func disableAllApplications() {
        enabledApplications.removeAll()
        
        // Update all profiles to disabled
        for (bundleIdentifier, profile) in profiles {
            let updatedProfile = AppProfile(
                bundleIdentifier: profile.bundleIdentifier,
                displayName: profile.displayName,
                accentColorHex: profile.accentColorHex,
                customShortcuts: profile.customShortcuts,
                windowBehavior: profile.windowBehavior,
                showPreviews: profile.showPreviews,
                isEnabled: false,
                priority: profile.priority
            )
            profiles[bundleIdentifier] = updatedProfile
        }
        
        saveEnabledApplications()
        saveProfiles()
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    // MARK: - Auto-Discovery
    
    func discoverAndRegisterApplications() {
        let runningApps = ApplicationDetector.getRunningApplications()
        
        for app in runningApps {
            if profiles[app.bundleIdentifier] == nil {
                let profile = createProfileForApplication(app)
                addProfile(profile)
                
                if profile.isEnabled {
                    enabledApplications.insert(app.bundleIdentifier)
                }
            }
        }
        
        saveEnabledApplications()
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
    
    // MARK: - Persistence
    
    private func loadProfiles() {
        guard let data = userDefaults.data(forKey: profilesKey),
              let decoded = try? JSONDecoder().decode([String: AppProfile].self, from: data) else {
            return
        }
        profiles = decoded
    }
    
    private func saveProfiles() {
        guard let encoded = try? JSONEncoder().encode(profiles) else {
            return
        }
        userDefaults.set(encoded, forKey: profilesKey)
    }
    
    private func loadEnabledApplications() {
        let saved = userDefaults.stringArray(forKey: enabledAppsKey) ?? []
        enabledApplications = Set(saved)
    }
    
    private func saveEnabledApplications() {
        userDefaults.set(Array(enabledApplications), forKey: enabledAppsKey)
    }
    
    private func setupDefaultProfiles() {
        // Add default profiles if they don't exist
        for defaultProfile in AppProfile.defaultProfiles {
            if profiles[defaultProfile.bundleIdentifier] == nil {
                profiles[defaultProfile.bundleIdentifier] = defaultProfile
                
                if defaultProfile.isEnabled {
                    enabledApplications.insert(defaultProfile.bundleIdentifier)
                }
            }
        }
        
        // Enable popular applications by default if not already configured
        for bundleIdentifier in Constants.DefaultApplications.enabled {
            if !profiles.keys.contains(bundleIdentifier) {
                // Create a basic profile for popular apps
                let profile = AppProfile(
                    bundleIdentifier: bundleIdentifier,
                    displayName: bundleIdentifier.components(separatedBy: ".").last?.capitalized ?? bundleIdentifier,
                    isEnabled: true
                )
                profiles[bundleIdentifier] = profile
            }
            enabledApplications.insert(bundleIdentifier)
        }
        
        saveProfiles()
        saveEnabledApplications()
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        profiles.removeAll()
        enabledApplications.removeAll()
        
        userDefaults.removeObject(forKey: profilesKey)
        userDefaults.removeObject(forKey: enabledAppsKey)
        
        setupDefaultProfiles()
        delegate?.registryService(self, didUpdateEnabledApplications: enabledApplications)
    }
}