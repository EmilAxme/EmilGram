import Foundation

struct UserResult: Codable {
    //MARK: - Properties
    let profileImage: ProfileImage

    //MARK: - Struct
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
}
