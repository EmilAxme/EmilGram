import Foundation

struct PhotoResult: Codable {
    // MARK: - Public Properties
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    // MARK: - Struct
    struct UrlsResult: Codable {
        let full: String
        let thumb: String
    }
}
