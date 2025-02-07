import UIKit

final class ProfileViewController: UIViewController{
    // MARK: - Properties
    private var userNameLabel: UILabel?
    private var userIDLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var image: UIImage?
    private var logOutButton: UIButton?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        setupUI()
        
        super.viewDidLoad()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        let profileImage = UIImage(named: "inkognito")
        let profileImageView = createImageView()
        profileImageView.image = profileImage
        
        let userIDLabel = createLabel(
            withText: "User ID",
            color: UIColor(named: "YP Gray (iOS)")!,
            font: UIFont.systemFont(ofSize: 13, weight: .regular)
        )
        self.userIDLabel = userIDLabel

        let descriptionLabel = createLabel(
            withText: "Description",
            color: UIColor(named: "YP White (iOS)")!,
            font: UIFont.systemFont(ofSize: 13, weight: .regular)
        )
        self.descriptionLabel = descriptionLabel

        let nameLabel = createLabel(
            withText: "Name",
            color: UIColor(named: "YP White (iOS)")!,
            font: UIFont.systemFont(ofSize: 23, weight: .bold)
        )
        self.userNameLabel = nameLabel
        
        let logOutImage = UIImage(named: "logOut_button")
        let logOutButton = UIButton.systemButton(with: logOutImage!, target: self, action: nil)
        addToView(logOutButton)
        self.logOutButton = logOutButton
        
        let labelsStackView = UIStackView(arrangedSubviews: [nameLabel, userIDLabel, descriptionLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        addToView(labelsStackView)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            labelsStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            labelsStackView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
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
        addToView(label)
        return label
    }
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        addToView(imageView)
        return imageView
    }
}
