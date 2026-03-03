import SwiftUI
import AVFoundation

@main
struct ChatterBoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsVM = SettingsViewModel()

    init() {
        AudioSessionManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsVM)
                .preferredColorScheme(.dark)
        }
    }
}
