import UIKit

final class SplashViewController: UIViewController {
    //MARK: Properties
    let showAuthenticationScreenSegueIdentifier = "showAuth"
    
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    //MARK: Override function
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oAuth2TokenStorage.token {
            print(token)
            fetchProfile(token)
        } else {
            print("Нет токена")
        }
        // Проверяем, есть ли токен в UserDefaults
        let savedToken = oAuth2TokenStorage.token
        
        print("Токен в UserDefaults: \(savedToken ?? "нет токена")")

        if savedToken != nil {
//            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: Private function's
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

//MARK: Extensions
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
           }
    }
}

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
                print("Ошибка получения профиля")
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
