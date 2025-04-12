import UIKit

final class SplashViewController: UIViewController {
    //MARK: - UI Properties
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Properties
    private var alert: AlertPresenter?
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    //MARK: - Override function
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alert = AlertPresenter(delegate: self)

        setupUI()
        if let token = oAuth2TokenStorage.token {
            print(token)
            fetchProfile(token)
        } else {
            showAuthController()
            print("Нет токена")
        }
    }
    
    // MARK: - Private function's
    func showNetworkError(title: String, message: String, buttonText: String, completion: (() -> Void)? = nil) {
        
        let errorAlert = AlertModel(
            title: title,
            message: message,
            buttonText: buttonText,
            completion: completion
        )
        
        guard let alert else { return }
        alert.presentAlert(with: errorAlert)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    func setupUI() {
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("Не удалось создать AuthViewController")
            return
        }

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    //MARK: - Helpers
    private func addToView(_ UI: UIView) {
        UI.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(UI)
    }
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        view.addSubview(imageView)
        return imageView
    }
}

//MARK: - Extensions
extension SplashViewController {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
       
        guard let token = oAuth2TokenStorage.token else {
            return
        }
        fetchProfile(token)
    }

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            

            switch result {
            case .success(let profile):

                profileImageService.fetchProfileImageURL(username: profile.username) { result in
                    switch result {
                    case .success(let url):
                        print("URL аватарки: \(url)")
                    case .failure(let error):
                        print("Не удалось получить URL аватарки: \(error.localizedDescription)")
                    }
                }
                self.switchToTabBarController()
            case .failure:
                showNetworkError(title: "Что-то пошло не так(", message: "Не удалось войти в систему", buttonText: "Ок") { [weak self] in
                    guard let self else { return }
                    self.showAuthController()
                }
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
        
    private func fetchOAuthToken(_ code: String) {
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                print("Ошибка при получении токена: \(error)")
                if OAuth2TokenStorage.shared.token != nil {
                    print("Несмотря на ошибку, токен уже сохранён. Переход в ленту.")
                    self.switchToTabBarController()
                } else {
                    print("Токен отсутствует. Не удалось выполнить вход.")
                }
            }
        }
    }
}
