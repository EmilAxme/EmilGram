import UIKit
import Kingfisher

final class ProfileViewController: UIViewController{
    //MARK: - Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var alert: AlertPresenter?
    private var shimmerAdded = false
    
    var animationLayers = Set<CALayer>()
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
        
        alert = AlertPresenter(delegate: self)
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        setupUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !shimmerAdded else { return }
        shimmerAdded = true

        addShimmer(to: profileImageView, cornerRadius: 35)
        addShimmer(to: nameLabel)
        addShimmer(to: userIDLabel)
        addShimmer(to: descriptionLabel)
        
        if profileImageService.avatarURL != nil {
            updateAvatar()
            removeShimmerLayers()
        }

    }
    
    // MARK: - Setup UI
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 50)
        profileImageView.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    private func updateProfileDetails(profile: Profile) {
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
        view.addToView(imageView)
        return imageView
    }
    
    private func addShimmer(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds 
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.8, 1]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmer")
    }
    
    private func removeShimmerLayers() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    // MARK: - private functions 
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
    @objc private func didTapLogoutButton(sender: UIButton) {
        showLogoutAlert(title: "Пока, пока!", message: "Уверены, что хотите выйти?", firstButtonText: "Да", firstButtonCompletion: logOut, secondButtonText: "Нет")
    }
    private func showLogoutAlert(title: String, message: String, firstButtonText: String, firstButtonCompletion: (() -> Void)? = nil, secondButtonText: String) {
        
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
    
    private func logOut() {
        profileLogoutService.logout()
        showAuthController()
    }
}

//MARK: - Extension's
extension ProfileViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
    }
}
