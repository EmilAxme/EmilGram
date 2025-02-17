import UIKit

final class AuthViewController: UIViewController {
    //MARK: - View's
    lazy var authButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(goToAuth), for: .touchUpInside)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor(named: "YP Black (iOS)") ?? .black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = UIColor(named: "YP White (iOS)")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        view.addToView(button)
        return button
    }()
    
    lazy var unsplashLogo: UIImageView = {
        let image = UIImage(named: "unsplashLogo")
        let imageView = UIImageView(image: image)
        view.addToView(imageView)
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        setupUI()
        configureBackButton()
        super.viewDidLoad()
    }
    
    //MARK: - private functions
    private func setupUI() {
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
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
    
    @objc private func goToAuth() {
        let authVC = WebViewViewController()
        navigationController?.pushViewController(authVC, animated: true)
    }
}
