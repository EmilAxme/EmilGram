import UIKit
import Kingfisher

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapLogout()
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(profile: profile)
        if profileImageService.avatarURL != nil {
            updateAvatar()
        }
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 50)
        view?.updateAvatar(url: url)
    }
    
    func didTapLogout() {
        view?.showLogoutAlert(title: "Пока, пока!", message: "Уверены, что хотите выйти?", firstButtonText: "Да", firstButtonCompletion: logOut, secondButtonText: "Нет")
    }

    func logOut() {
        profileLogoutService.logout()
        view?.showAuthController()
    }

    
}
