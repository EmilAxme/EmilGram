import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    //MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    //MARK: - Properties
    let tokenKey = "token"
    var token : String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        
        set {
            if let value = newValue {
                            KeychainWrapper.standard.set(value, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
