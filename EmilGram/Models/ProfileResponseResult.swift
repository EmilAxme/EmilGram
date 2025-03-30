import Foundation

struct ProfileResponseResult: Decodable {
    // MARK: - Public Properties
    let username: String
    let name: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
}
