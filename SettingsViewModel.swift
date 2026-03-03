import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var quietModeEnabled: Bool {
        didSet { UserDefaults.standard.set(quietModeEnabled, forKey: "chatterbox.quietMode") }
    }
    init() {
        self.quietModeEnabled = UserDefaults.standard.bool(forKey: "chatterbox.quietMode")
    }
}
