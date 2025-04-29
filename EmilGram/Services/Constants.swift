import Foundation

// MARK: - CONST
enum Constants {
    static let accessKey: String = "m0BWAvSbULbPNdNGD5rs-NxadwWajbx9JffzfpMx8FA"
    static let secretKey: String = "1wZFF7GYVZ3YNMbIxQsSMoUSiHlxICHF33O9DEvdvu4"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    
    static let accessScope: String = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://unsplash.com/") ?? nil
    static let defaultAPIBaseURL = URL(string: "https://api.unsplash.com/") ?? nil
}
