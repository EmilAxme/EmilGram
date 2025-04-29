import UIKit
import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    //MARK: - Propert's
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    weak var delegate: AuthViewControllerDelegate?
    
    //MARK: - Singleton
    static let shared = ProfileLogoutService()
    private init() {}
    
    //MARK: - Function's
    func logout() {
        cleanCookies()
    }
    
    //MARK: - Private Function's
    private func cleanCookies() {
          HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
          WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
             records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
             }
          }
        imagesListService.removePhotosFromDisk()
        profileImageService.removeProfilePhoto()
        profileService.removeProfile()
       }
}
