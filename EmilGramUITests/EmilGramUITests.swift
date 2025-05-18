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
         
        let webView = app.webViews["WebViewVC"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("email")
        XCUIDevice.shared.press(.home)
        XCUIDevice.shared.press(.home) // дважды – свернуть и вернуться
        XCUIApplication().activate()    // вернуться в приложение
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("password")
        XCUIDevice.shared.press(.home)
        XCUIDevice.shared.press(.home) // дважды – свернуть и вернуться
        XCUIApplication().activate()    // вернуться в приложение
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        webView.buttons["Login"].tap()
        
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        print(app.debugDescription)
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables

        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.swipeUp()

        let secondCell = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))

        let likeButton = secondCell.buttons["like button"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        likeButton.tap()

        secondCell.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
    }
    
    func testProfile() throws {
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logOutButton"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }
}
