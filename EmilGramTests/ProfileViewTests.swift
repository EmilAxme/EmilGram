import XCTest
@testable import EmilGram

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        
        //when
        _ = viewController.view
        
        
        //then
        XCTAssertTrue(presenter.didViewDidLoadCalled)
    }
    
    func testViewControllerCallsDidTapLogout() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // загружаем view, чтобы вызвать viewDidLoad и настроить UI
        _ = viewController.view
        
        // when
        viewController.didTapLogoutButton(sender: UIButton())
        
        // then
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
    
    func testDidTapLogoutCallsShowLogoutAlertAndThenShowAuthController() {
        // given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewControllerSpy
        
        // when
        presenter.didTapLogout()
        
        // симулируем нажатие на "Да"
        viewControllerSpy.simulateFirstButtonTap()
        
        // then
        XCTAssertTrue(viewControllerSpy.didShowLogoutAlert)
        XCTAssertTrue(viewControllerSpy.didShowAuthController)
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        
        //when
        presenter.updateAvatar()
        
        
        //then
        XCTAssertTrue(viewControllerSpy.didCallUpdateAvatar)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        
        //when
        presenter.viewDidLoad()
        
        
        //then
        XCTAssertTrue(viewControllerSpy.didCallUpdateProfile)
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var didCallUpdateProfile = false
    var didCallUpdateAvatar = false
    var didShowAuthController = false
    var didShowLogoutAlert = false
    
    private var firstButtonAction: (() -> Void)?
    
    func showAuthController() {
        didShowAuthController = true
    }
    
    func updateAvatar(url: URL) {
        didCallUpdateAvatar = true
    }
    
    func updateProfileDetails(profile: EmilGram.Profile) {
        didCallUpdateProfile = true
    }
    
    func authViewController(_ vc: EmilGram.AuthViewController, didAuthenticateWithCode code: String) {
        
    }

    func showLogoutAlert(title: String, message: String, firstButtonText: String, firstButtonCompletion: (() -> Void)?, secondButtonText: String) {
        didShowLogoutAlert = true
        firstButtonAction = firstButtonCompletion
    }

    func simulateFirstButtonTap() {
        firstButtonAction?()
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var didTapLogoutCalled = false
    var didViewDidLoadCalled = false
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func viewDidLoad() {
        didViewDidLoadCalled = true
    }
    
    
}
