import UIKit

final class ProfileViewController: UIViewController{
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
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
        let profileImage = UIImage(named: "profilePhoto")
        let profileImageView = createImageView()
        profileImageView.image = profileImage
        return profileImageView
    }()
    private lazy var logOutButton: UIButton = {
        let logOutImage = UIImage(named: "logOut_button")
        guard let logOutImage else { return UIButton() }
        let logOutButton = UIButton.systemButton(with: logOutImage, target: self, action: nil)
        view.addToView(logOutButton)
        return logOutButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
        }
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        setupUI()
    }
    
    // MARK: - Setup UI
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio
        userIDLabel.text = profile.loginName
    }
    
    
    
    private func setupUI() {
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
}
