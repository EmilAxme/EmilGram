//
//  EmilGramTests.swift
//  EmilGramTests
//
//  Created by Emil on 25.01.2025.
//

import XCTest
@testable import EmilGram

final class EmilGramTests: XCTestCase {
    
    func testFetchPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage(completion: { _ in })

        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(service.photos.count, 10)
    }
    
}
