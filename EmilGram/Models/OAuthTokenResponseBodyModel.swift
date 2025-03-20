import Foundation

struct OAuthTokenResponseBody: Codable {
    var accessToken: String
    var tokenType: String
    var scope: String
    var createdAt: Int
}
