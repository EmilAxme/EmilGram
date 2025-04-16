import UIKit
import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    weak var delegate: AuthViewControllerDelegate?
    
    
    private init() {}
    
    func logout() {
        cleanCookies()
    }
    
    private func cleanCookies() {
          // Очищаем все куки из хранилища
          HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
          // Запрашиваем все данные из локального хранилища
          WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
             // Массив полученных записей удаляем из хранилища
             records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
             }
          }
        imagesListService.removePhotosFromDisk()
        profileImageService.removeProfilePhoto()
        profileService.removeProfile()
       }
}
