import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    lazy var webView: WKWebView = {
        var WKWebView = WKWebView()
        view.addToView(WKWebView)
        WKWebView.backgroundColor = .white
        return WKWebView
        
    
    }()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        
    }
    
    func setupUI() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
}
