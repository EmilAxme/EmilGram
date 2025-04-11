import Foundation

public struct Profile {
    // MARK: - Public Properties
    var username: String
    var name: String
    var firstName: String
    var lastName: String
    var loginName: String {
        get {
            return "@\(username)"
        }
    }
    var bio: String?
    
    //MARK: - Init's
    init(username: String, name: String, firstName: String, lastName: String, bio: String?) {
        self.username = username
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
    }
    
    init(from result: ProfileResponseResult) {
        self.username = result.username
        self.name = result.name ?? ""
        self.firstName = result.firstName ?? ""
        self.lastName = result.lastName ?? ""
        self.bio = result.bio ?? ""
    }
    
}
