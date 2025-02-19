import UIKit

final class AuthViewController: UIViewController {
    //MARK: - View's
    @IBOutlet weak var authButton: UIButton!
    
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
        
        authButton.addTarget(self, action: #selector(goToAuth), for: .touchUpInside)
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
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
    
    @objc private func goToAuth() {
        let authVC = WebViewViewController()
        navigationController?.pushViewController(authVC, animated: true)
    }
}
