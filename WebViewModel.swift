import SwiftUI
import WebKit
import Combine

@MainActor
final class WebViewModel: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var hasError  = false
    @Published private(set) var errorMsg  = ""

    private weak var webView: WKWebView?
    private var bag = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .cbInterruptionBegan)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.js("if(window.__applyQuietMode)window.__applyQuietMode(true)") }
            .store(in: &bag)
        NotificationCenter.default.publisher(for: .cbInterruptionEnded)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.js("if(window.__applyQuietMode)window.__applyQuietMode(false)") }
            .store(in: &bag)
    }

    func register(webView: WKWebView) { self.webView = webView }

    func setLoading(_ v: Bool) { isLoading = v; if v { hasError = false } }
    func setError(_ msg: String?) {
        if let msg { errorMsg = msg; hasError = true; isLoading = false }
        else { hasError = false; errorMsg = "" }
    }

    func reload() { setError(nil); setLoading(true); webView?.reload() }

    func applyQuietMode(enabled: Bool) {
        js("if(window.__applyQuietMode)window.__applyQuietMode(\(enabled));")
    }

    private func js(_ script: String) {
        webView?.evaluateJavaScript(script) { _, err in
            if let err { print("[VM]", err.localizedDescription) }
        }
    }
}
