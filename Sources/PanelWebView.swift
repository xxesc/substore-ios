import SwiftUI
import WebKit

struct PanelWebView: UIViewRepresentable {
    let reloadToken: UUID
    @Binding var progress: Double
    let onFirstLoad: () -> Void

    @EnvironmentObject private var config: AppConfig

    func makeCoordinator() -> Coordinator {
        Coordinator(config: config, progress: $progress, onFirstLoad: onFirstLoad)
    }

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.websiteDataStore = .default()

        // 让前端一打开就认为后端已配置，跳过「后端连接配置」弹窗
        let bootstrap = """
        (function(){
          try {
            var name = 'Panel';
            localStorage.setItem('backendConfigured', 'true');
            localStorage.setItem('hostAPI', JSON.stringify({
              current: name,
              apis: [{ name: name, url: location.origin }]
            }));
          } catch (e) {}
        })();
        """
        cfg.userContentController.addUserScript(
            WKUserScript(source: bootstrap,
                         injectionTime: .atDocumentStart,
                         forMainFrameOnly: true)
        )

        let web = WKWebView(frame: .zero, configuration: cfg)
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        web.allowsBackForwardNavigationGestures = true
        web.scrollView.contentInsetAdjustmentBehavior = .automatic
        web.isOpaque = false
        web.backgroundColor = .clear

        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor(red: 0.26, green: 0.72, blue: 0.51, alpha: 1)
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.pulled), for: .valueChanged)
        web.scrollView.refreshControl = refresh

        context.coordinator.webView = web
        context.coordinator.startObserving()
        context.coordinator.load(config.baseURL)
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        context.coordinator.config = config
        if context.coordinator.lastToken != reloadToken {
            context.coordinator.lastToken = reloadToken
            context.coordinator.load(config.baseURL)
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.stopObserving()
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var config: AppConfig
        @Binding var progress: Double
        let onFirstLoad: () -> Void
        weak var webView: WKWebView?
        var lastToken: UUID?
        private var observation: NSKeyValueObservation?
        private var didCallFirstLoad = false

        init(config: AppConfig, progress: Binding<Double>, onFirstLoad: @escaping () -> Void) {
            self.config = config
            self._progress = progress
            self.onFirstLoad = onFirstLoad
        }

        func startObserving() {
            guard let webView else { return }
            observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] web, _ in
                DispatchQueue.main.async {
                    self?.progress = web.estimatedProgress
                }
            }
        }

        func stopObserving() {
            observation?.invalidate()
            observation = nil
        }

        func load(_ urlString: String) {
            guard let url = URL(string: urlString) else { return }
            progress = 0
            webView?.load(URLRequest(url: url))
        }

        @objc func pulled() {
            webView?.reload()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
            progress = 1
            if !didCallFirstLoad {
                didCallFirstLoad = true
                onFirstLoad()
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
            progress = 1
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
            progress = 1
            if !didCallFirstLoad {
                didCallFirstLoad = true
                onFirstLoad()
            }
        }

        // Basic / Digest 认证自动填充
        func webView(_ webView: WKWebView,
                     didReceive challenge: URLAuthenticationChallenge,
                     completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let method = challenge.protectionSpace.authenticationMethod
            if method == NSURLAuthenticationMethodHTTPBasic || method == NSURLAuthenticationMethodHTTPDigest {
                guard !config.password.isEmpty else {
                    completionHandler(.performDefaultHandling, nil)
                    return
                }
                let credential = URLCredential(user: config.username,
                                               password: config.password,
                                               persistence: .forSession)
                completionHandler(.useCredential, credential)
                return
            }
            completionHandler(.performDefaultHandling, nil)
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}
