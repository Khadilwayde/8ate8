import Foundation

enum AppConfig {

    // Remote URL strategy — ChatterBox has API routes + Redis, cannot static export
    static let useLocalBundle = false

    // TODO: Replace with your deployed Vercel / server URL
    static let remoteURL = "https://your-chatterbox-app.vercel.app"

    // External links not in this list open in Safari
    static let allowedHosts = [
        "your-chatterbox-app.vercel.app",
        "localhost",
        "127.0.0.1"
    ]

    static let appName     = "ChatterBox"
    static let bundleID    = "com.yourcompany.chatterbox"
    static let appVersion  = "1.0.0"
    static let buildNumber = "1"

    static let requestTimeout: TimeInterval         = 30
    static let cachePolicy: URLRequest.CachePolicy  = .returnCacheDataElseLoad

    static let quietModeKey = "chatterbox.quietMode"
}
