import SwiftUI
import WebKit
import AVFoundation

struct WebViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        let wv = build(coordinator: context.coordinator)
        viewModel.register(webView: wv)
        load(wv)
        return wv
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(viewModel: viewModel) }

    private func build(coordinator: Coordinator) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        let ucc = WKUserContentController()
        ucc.add(coordinator, name: "nativeBridge")
        ucc.addUserScript(WKUserScript(source: startupJS, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        config.userContentController = ucc

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = coordinator
        wv.uiDelegate = coordinator
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.scrollView.bounces = false
        wv.isOpaque = false
        wv.backgroundColor = .black
        wv.scrollView.backgroundColor = .black
        wv.allowsBackForwardNavigationGestures = true
        if #available(iOS 16.4, *) { wv.isInspectable = false }
        return wv
    }

    private func load(_ wv: WKWebView) {
        guard let url = URL(string: "https://your-chatterbox-app.vercel.app") else { return }
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        wv.load(req)
    }

    private let startupJS = """
    (function(){
        if(!document.querySelector('meta[name="viewport"]')){
            var m=document.createElement('meta');
            m.name='viewport';
            m.content='width=device-width,initial-scale=1,maximum-scale=1,viewport-fit=cover';
            if(document.head)document.head.appendChild(m);
        }
        window.nativeApp={platform:'ios',version:'1.0',appName:'ChatterBox',
            postMessage:function(p){try{window.webkit.messageHandlers.nativeBridge.postMessage(p);}catch(e){}}};
        window.__quietMode=false;
        window.__applyQuietMode=function(enabled){
            window.__quietMode=enabled;
            document.querySelectorAll('audio,video').forEach(function(el){el.muted=enabled;});
            window.dispatchEvent(new CustomEvent('quietModeChanged',{detail:{enabled:enabled}}));
        };
        new MutationObserver(function(muts){
            if(!window.__quietMode)return;
            muts.forEach(function(m){m.addedNodes.forEach(function(n){
                if(n.nodeName==='AUDIO'||n.nodeName==='VIDEO'){n.muted=true;}
                if(n.querySelectorAll)n.querySelectorAll('audio,video').forEach(function(e){e.muted=true;});
            });});
        }).observe(document.documentElement,{childList:true,subtree:true});
    })();
    """
}

extension WebViewContainer {
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        private weak var vm: WebViewModel?
        init(viewModel: WebViewModel) { vm = viewModel }

        func webView(_ wv: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            vm?.setLoading(true); vm?.setError(nil)
        }
        func webView(_ wv: WKWebView, didFinish _: WKNavigation!) { vm?.setLoading(false) }
        func webView(_ wv: WKWebView, didFail _: WKNavigation!, withError e: Error) { handle(e) }
        func webView(_ wv: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError e: Error) { handle(e) }

        private func handle(_ error: Error) {
            let e = error as NSError
            guard e.code != NSURLErrorCancelled else { return }
            vm?.setLoading(false); vm?.setError(error.localizedDescription)
        }

        func webView(_ wv: WKWebView, decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = action.request.url else { decisionHandler(.cancel); return }
            let scheme = url.scheme?.lowercased() ?? ""
            guard ["https","http","about","blob","data"].contains(scheme) else {
                if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
                decisionHandler(.cancel); return
            }
            if action.targetFrame?.isMainFrame == true, let host = url.host {
                let allowed = ["your-chatterbox-app.vercel.app","localhost","127.0.0.1"]
                if !allowed.contains(where: { host.hasSuffix($0) }) {
                    UIApplication.shared.open(url); decisionHandler(.cancel); return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ wv: WKWebView, runJavaScriptAlertPanelWithMessage msg: String,
                     initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let a = UIAlertController(title: "ChatterBox", message: msg, preferredStyle: .alert)
            a.addAction(.init(title: "OK", style: .default) { _ in completionHandler() })
            topVC()?.present(a, animated: true)
        }

        func userContentController(_ ucc: WKUserContentController, didReceive msg: WKScriptMessage) {
            guard msg.name == "nativeBridge",
                  let body = msg.body as? [String: Any],
                  let action = body["action"] as? String else { return }
            DispatchQueue.main.async {
                switch action {
                case "requestMicPermission":
                    AVAudioSession.sharedInstance().requestRecordPermission { _ in }
                case "audioSessionActivate":
                    AudioSessionManager.shared.activate()
                case "haptic":
                    let g = UIImpactFeedbackGenerator(style: .medium); g.impactOccurred()
                case "log":
                    if let m = body["message"] as? String { print("[Web]", m) }
                default: break
                }
            }
        }

        private func topVC() -> UIViewController? {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }.first { $0.isKeyWindow }?.rootViewController
        }
    }
}
