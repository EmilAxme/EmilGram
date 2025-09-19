import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject, AuthViewControllerDelegate {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func showAuthController()
    func showLogoutAlert(title: String, message: String, firstButtonText: String, firstButtonCompletion: (() -> Void)?, secondButtonText: String)
    func updateAvatar(url: URL)
    func updateProfileDetails(profile: Profile)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    //MARK: - Properties
    var presenter: ProfilePresenterProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let shimmerService = ShimmerService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var alert: AlertPresenter?
    private var shimmerAdded = false
    
    // MARK: - View Properties
    private lazy var nameLabel: UILabel = {
        let nameLabel = createLabel(
            withText: "Екатерина Новикова",
            color: UIColor(named: "YP White (iOS)") ?? .white,
            font: UIFont.systemFont(ofSize: 23, weight: .bold)
        )
        return nameLabel
    }()
    private lazy var userIDLabel: UILabel = {
        let userIDLabel = createLabel(
            withText: "@ekaterina_nov",
            color: UIColor(named: "YP Gray (iOS)") ?? .gray,
            font: UIFont.systemFont(ofSize: 13, weight: .regular)
        )
        return userIDLabel
    }()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = createLabel(
            withText: "Hello, world!",
            color: UIColor(named: "YP White (iOS)") ?? .white,
            font: UIFont.systemFont(ofSize: 13, weight: .regular)
        )
        return descriptionLabel
    }()
    private lazy var profileImageView: UIImageView = {
        let profileImageView = createImageView()
        return profileImageView
    }()
    private lazy var logOutButton: UIButton = {
        let logOutImage = UIImage(named: "logOut_button")
        guard let logOutImage else { return UIButton() }
        let logOutButton = UIButton.systemButton(with: logOutImage, target: self, action: #selector(didTapLogoutButton))
        view.addToView(logOutButton)
        return logOutButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutButton.accessibilityIdentifier = "logOutButton"
        nameLabel.accessibilityIdentifier = "Name Lastname"
        userIDLabel.accessibilityIdentifier = "@username"
        alert = AlertPresenter(delegate: self)
        setupUI()
        
        presenter?.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        guard !shimmerAdded else { return }
        shimmerAdded = true

        shimmerService.addShimmer(to: profileImageView, cornerRadius: 50)
        shimmerService.addShimmer(to: nameLabel)
        shimmerService.addShimmer(to: userIDLabel)
        shimmerService.addShimmer(to: descriptionLabel)

    }
    
    // MARK: - UI Functions
    func updateAvatar(url: URL){
        profileImageView.kf.setImage(with: url) { [weak self] _ in
            guard let self else { return }
            self.shimmerService.removeShimmerLayers()
        }
    }
    
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio
        userIDLabel.text = profile.loginName
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        let labelsStackView = UIStackView(arrangedSubviews: [nameLabel, userIDLabel, descriptionLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        view.addToView(labelsStackView)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            labelsStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            labelsStackView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            logOutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    
    // MARK: - Helpers
    
    private func addToView(_ UI: UIView) {
        UI.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(UI)
    }
    
    private func createLabel(withText text: String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        view.addToView(label)
        return label
    }
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        return imageView
    }
    
    // MARK: - functions 
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("Не удалось создать AuthViewController")
            return
        }

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    func showLogoutAlert(title: String, message: String, firstButtonText: String, firstButtonCompletion: (() -> Void)? = nil, secondButtonText: String) {
        
        let errorAlert = AlertModel(
            title: title,
            message: message,
            buttonText: firstButtonText,
            secondButtonText: secondButtonText,
            completion: firstButtonCompletion
        )
        
        guard let alert else { return }
        alert.presentAlert(with: errorAlert)
    }
    
    @objc func didTapLogoutButton(sender: UIButton) {
            presenter?.didTapLogout()
        }
}

//MARK: - Extension's
extension ProfileViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
    }
}
