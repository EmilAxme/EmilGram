import Foundation

struct OAuthTokenResponseBody: Codable {
    // MARK: - Public Properties
    var accessToken: String
    var tokenType: String
    var scope: String
    var createdAt: Int
}
