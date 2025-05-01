import UIKit
import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    //MARK: - Singleton
    static let shared = ProfileLogoutService()
    private init() {}
    
    //MARK: - Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    weak var delegate: AuthViewControllerDelegate?
    
    
    //MARK: - Functions
    func logout() {
        cleanCookies()
    }
    
    //MARK: - Private Functions
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
