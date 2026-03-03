import Foundation

enum AppConfig {

    // Remote URL strategy — ChatterBox has API routes + Redis, cannot static export
    static let useLocalBundle = false

    // TODO: Replace with your deployed Vercel / server URL
    static let remoteURL = "https://chatterbox.khadilwayde.icu"
    // External links not in this list open in Safari
    static let allowedHosts = [
        "chatterbox.khadilwayde.icu",
        "127.0.0.1"
    ]

    static let appName     = "ChatterBox"
    static let bundleID = "icu.khadilwayde.chatterbox"
    static let appVersion  = "1.0.0"
    static let buildNumber = "1"

    static let requestTimeout: TimeInterval         = 30
    static let cachePolicy: URLRequest.CachePolicy  = .returnCacheDataElseLoad

    static let quietModeKey = "chatterbox.quietMode"
}
