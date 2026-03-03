import AVFoundation
import os.log

final class AudioSessionManager {
    static let shared = AudioSessionManager()
    private let log = Logger(subsystem: "com.yourcompany.chatterbox", category: "Audio")
    private let session = AVAudioSession.sharedInstance()
    private init() {}

    func configure() {
        do {
            try session.setCategory(.playback, mode: .default,
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
        } catch { log.error("configure: \(error.localizedDescription)") }
    }

    func activate() {
        do { try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch { log.error("activate: \(error.localizedDescription)") }
    }

    func deactivate() {
        do { try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch { log.error("deactivate: \(error.localizedDescription)") }
    }

    func requestMicPermission(completion: @escaping (Bool) -> Void) {
        switch session.recordPermission {
        case .granted: completion(true)
        case .denied: completion(false)
        case .undetermined:
            session.requestRecordPermission { g in DispatchQueue.main.async { completion(g) } }
        @unknown default: completion(false)
        }
    }
}
