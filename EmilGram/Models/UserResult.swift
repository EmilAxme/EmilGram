import Foundation

struct UserResult: Codable {
    //MARK: - Property
    let profileImage: ProfileImage

    //MARK: - Struct
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
}
