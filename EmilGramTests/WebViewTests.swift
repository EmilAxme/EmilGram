

import XCTest
@testable import EmilGram

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        
        //when
        _ = viewController.view
        
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewControllerSpy = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        
        //when
        presenter.viewDidLoad()
        
        
        //then
        XCTAssertTrue(viewControllerSpy.loadRequestCalled)
    }
    
    func testProgressVisibleLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.999999
        
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        
        //when
        let url = authHelper.authURL()
        guard let url = url?.absoluteString else {
            XCTAssert(false, "❌ authHelper.authURL() вернул nil — URL авторизации не сформирован")
            return
        }
        let urlString = url
        
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeExtractionFromRedirectURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native") else {
            XCTAssert(false, "❌ Не удалось создать URLComponents — проверь строку URL")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        
        
        //when
        guard let url = urlComponents.url else {
            XCTAssert(false, "❌ Не удалось получить URL из URLComponents — возможно, они некорректно заданы")
            return
        }
        let code = authHelper.code(from: url)
        
        
        //then
        XCTAssertEqual(code, "test code")
    }
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
