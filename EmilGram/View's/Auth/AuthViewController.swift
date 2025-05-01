import UIKit
import ProgressHUD
final class AuthViewController: UIViewController {
    //MARK: - Properties
    private let oAuth2Service = OAuth2Service.shared
    private var alert: AlertPresenter?

    weak var delegate: AuthViewControllerDelegate?
    
    //MARK: - View's
    let showWebViewSegueIdentifier = "ShowWebView"
    @IBOutlet private var authButton: UIButton!
    
    lazy var unsplashLogo: UIImageView = {
        let image = UIImage(named: "unsplashLogo")
        let imageView = UIImageView(image: image)
        view.addToView(imageView)
        return imageView
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        view.inputViewController?.modalPresentationStyle = .fullScreen
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        setupUI()
        configureBackButton()
        
        alert = AlertPresenter(delegate: self)
        
        super.viewDidLoad()
    }
    //MARK: - Override functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    //MARK: - private functions
    private func setupUI() {
        
        authButton.setTitle("Войти", for: .normal)
        authButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        authButton.setTitleColor(UIColor(named: "YP Black (iOS)") ?? .black, for: .normal)
        authButton.backgroundColor = UIColor(named: "YP White (iOS)")
        authButton.layer.cornerRadius = 16
        authButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            authButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            authButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            authButton.heightAnchor.constraint(equalToConstant: 48),
            unsplashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unsplashLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 236),
            unsplashLogo.widthAnchor.constraint(equalToConstant: 60),
            unsplashLogo.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addToView(_ UI: UIView) {
        UI.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(UI)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func makeErrorAlert(title: String, message: String?, buttonText: String) {
        let errorAlert = AlertModel(title: title,
                                    message: message ?? nil,
                                    buttonText: buttonText, secondButtonText: nil)
        
        guard let alert else { return }
        
        alert.presentAlert(with: errorAlert)
    }
}

// MARK: - Extension's and Protocol's

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(code: code, completion: { result in
            switch result {
            case .success(let token):
                UIBlockingProgressHUD.dismiss()
                print("Токен получен и сохранен: \(token)")
                
                
                self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                self.dismiss(animated: true)
                
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.makeErrorAlert(title: "Что-то пошло не так", message: "Не удалось войти в систему", buttonText: "Ок")
                print("Ошибка получения токена: \(error)")
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    
}

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

