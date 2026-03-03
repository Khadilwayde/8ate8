# ChatterBox iOS Wrapper — Phase 1-4 Core Swift Files

## PHASE 1: INTEGRATION STRATEGY

**Decision: Remote URL (mandatory)**

From project inspection:
- `app/api/rooms/route.ts` — server room creation
- `app/api/rooms/[code]/join/route.ts` — join API  
- `app/api/rooms/[code]/messages/route.ts` — audio message polling
- `lib/redis.ts` — Redis-backed state
- Tailwind v4 build pipeline required

Static export would silently break all API routes. ChatterBox MUST be deployed and loaded over HTTPS.

**Package manager:** pnpm | **App:** ChatterBox (walkie-talkie PTT voice)

---

## FOLDER STRUCTURE

```
ChatterBox/
├── App/
│   ├── ChatterBoxApp.swift     ← @main entry
│   ├── AppDelegate.swift       ← lifecycle + audio interruptions
│   └── AppConfig.swift         ← all constants
├── Views/
│   ├── ContentView.swift       ← root shell
│   ├── LoadingView.swift       ← loading overlay
│   ├── ErrorView.swift         ← network error screen
│   └── SettingsView.swift      ← Quiet Mode sheet
├── ViewModels/
│   ├── WebViewModel.swift      ← WKWebView state
│   └── SettingsViewModel.swift ← Quiet Mode + persistence
├── Services/
│   └── AudioSessionManager.swift ← AVAudioSession
├── WebView/
│   └── WebViewContainer.swift  ← UIViewRepresentable
└── Resources/
    ├── Info.plist
    └── ChatterBox.entitlements
```

---

## AppConfig.swift

```swift
import Foundation

enum AppConfig {
    // false = Remote URL (required for ChatterBox)
    static let useLocalBundle: Bool = false

    // !! Replace with your deployed Vercel / server URL !!
    static let remoteURL: String = "https://your-chatterbox-app.vercel.app"

    // Links outside this list open in Safari
    static let allowedHosts: [String] = [
        "your-chatterbox-app.vercel.app",
        "localhost",
        "127.0.0.1"
    ]

    static let appName      = "ChatterBox"
    static let bundleID     = "com.yourcompany.chatterbox"
    static let appVersion   = "1.0.0"
    static let buildNumber  = "1"

    static let requestTimeout: TimeInterval = 30
    static let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad

    static let quietModeKey = "chatterbox.quietMode"
}
```

---

## ChatterBoxApp.swift

```swift
import SwiftUI
import AVFoundation

@main
struct ChatterBoxApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsVM = SettingsViewModel()

    init() {
        // Configure AVAudioSession before any WKWebView loads media
        AudioSessionManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsVM)
                .preferredColorScheme(.dark) // ChatterBox is dark-only
        }
    }
}
```

---

## AppDelegate.swift

```swift
import UIKit
import AVFoundation

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AudioSessionManager.shared.activate()
        registerForNotifications()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Re-activate to prevent system teardown between PTT transmissions
        AudioSessionManager.shared.activate()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AudioSessionManager.shared.activate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AudioSessionManager.shared.deactivate()
    }

    private func registerForNotifications() {
        let session = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification, object: session)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification, object: session)
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            // Phone call etc. — tell web layer to pause PTT
            NotificationCenter.default.post(name: .cbInterruptionBegan, object: nil)
        case .ended:
            let optValue = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            if AVAudioSession.InterruptionOptions(rawValue: optValue).contains(.shouldResume) {
                AudioSessionManager.shared.activate()
                NotificationCenter.default.post(name: .cbInterruptionEnded, object: nil)
            }
        @unknown default: break
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        // Re-activate after headphones in/out, AirPods connect/disconnect
        AudioSessionManager.shared.activate()
    }
}

extension Notification.Name {
    static let cbInterruptionBegan = Notification.Name("cb.interruptionBegan")
    static let cbInterruptionEnded = Notification.Name("cb.interruptionEnded")
}
```
