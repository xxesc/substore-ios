import SwiftUI
import WebKit

struct PanelWebView: UIViewRepresentable {
    let reloadToken: UUID
    @EnvironmentObject private var config: AppConfig

    func makeCoordinator() -> Coordinator { Coordinator(config: config) }

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.websiteDataStore = .default()

        // 让前端一打开就认为是"已连接同源后端"，不再弹「后端连接配置」
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
        web.scrollView.contentInsetAdjustmentBehavior = .never

        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.pulled), for: .valueChanged)
        web.scrollView.refreshControl = refresh

        context.coordinator.webView = web
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

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var config: AppConfig
        weak var webView: WKWebView?
        var lastToken: UUID?

        init(config: AppConfig) {
            self.config = config
        }

        func load(_ urlString: String) {
            guard let url = URL(string: urlString) else { return }
            webView?.load(URLRequest(url: url))
        }

        @objc func pulled() {
            webView?.reload()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
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

        // 新窗口里的链接留在当前 WebView
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
