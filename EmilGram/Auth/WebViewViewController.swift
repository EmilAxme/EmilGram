import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    //MARK: - View's
    lazy var webView: WKWebView = {
        var WKWebView = WKWebView()
        view.addToView(WKWebView)
        WKWebView.backgroundColor = .white
        return WKWebView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        setupUI()
        loadAuthView()
        super.viewDidLoad()
        
    }
    //MARK: - Private function's
    private func setupUI() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Не удалось загрузить url страницы авторизации")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Не удалось совершить запрос")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

    //MARK: - ENUM
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
