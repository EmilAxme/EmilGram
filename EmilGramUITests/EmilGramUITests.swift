//
//  EmilGramUITests.swift
//  EmilGramUITests
//
//  Created by Emil on 25.01.2025.
//

import XCTest

final class EmilGramUITests: XCTestCase {
    private let app = XCUIApplication()
    

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app.launch()
        
        continueAfterFailure = false
    }
    
    
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["ShowWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("emil.azmedov@mail.ru")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("Zaur1977")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        print(app.debugDescription)
    }
    
    func testFeed() throws {
        
    }
    
    func testProfile() throws {
        
    }
}
