import UIKit
import AVFoundation

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AudioSessionManager.shared.activate()
        registerForNotifications()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AudioSessionManager.shared.activate()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        AudioSessionManager.shared.activate()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        AudioSessionManager.shared.deactivate()
    }

    private func registerForNotifications() {
        let s = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification, object: s)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification, object: s)
    }

    @objc private func handleInterruption(_ n: Notification) {
        guard let info = n.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        switch type {
        case .began:
            NotificationCenter.default.post(name: .cbInterruptionBegan, object: nil)
        case .ended:
            let opts = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            if AVAudioSession.InterruptionOptions(rawValue: opts).contains(.shouldResume) {
                AudioSessionManager.shared.activate()
                NotificationCenter.default.post(name: .cbInterruptionEnded, object: nil)
            }
        @unknown default: break
        }
    }

    @objc private func handleRouteChange(_ n: Notification) {
        AudioSessionManager.shared.activate()
    }
}

extension Notification.Name {
    static let cbInterruptionBegan = Notification.Name("cb.interruptionBegan")
    static let cbInterruptionEnded = Notification.Name("cb.interruptionEnded")
}
