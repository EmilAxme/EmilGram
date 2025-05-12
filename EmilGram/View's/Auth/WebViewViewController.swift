import UIKit
import WebKit

// MARK: - Protocol
public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
}

// MARK: - Final Class
final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    //MARK: - Properties
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    //MARK: - Lazy Properties
    private lazy var progressView: UIProgressView = {
        var progressView = UIProgressView()
        view.addToView(progressView)
        progressView.tintColor = UIColor(named: "YP Black (iOS)")
        return progressView
    }()
    
    private lazy var webView: WKWebView = {
        var WKWebView = WKWebView()
        view.addToView(WKWebView)
        WKWebView.backgroundColor = .white
        return WKWebView
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        setupUI()
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    
    //MARK: - Observe Object's
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    //MARK: - Private functions
    private func setupUI() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    //MARK: - functions
    func load(request: URLRequest) {
        webView.load(request)
    }

}

    //MARK: - ENUM
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
    //MARK: - Extension
extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code"})
        {
            return codeItem.value
        }
        else {
            return nil
        }
    }
}
