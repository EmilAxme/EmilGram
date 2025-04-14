import Foundation
 
final class ProfileImageService {
    //MARK: - Notification
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    //MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    //MARK: - Private properties
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastCode: String?
    private var profileService = ProfileService.shared
    
    //MARK: - Functions
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
                
        guard let request = makeUserProfileRequest(username: username) else {
            completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profileImageResult):
                    let avatarURL = profileImageResult.profileImage.small
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                case .failure(let error):
                    if let error = error as? NetworkError {
                        handleNetworkError(error, service: "[ProfileImageService.fetchProfileImageURL]", completion: completion)
                    } else {
                        print("[ProfileImageService.fetchProfileImageURL]: Error - Неизвестная ошибка: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeUserProfileRequest(username: String) -> URLRequest? {
        guard let baseUrl = Constants.defaultAPIBaseURL?.appendingPathComponent("users/\(username)") else {
            print("Ошибка: невозможно создать baseURL")
            return nil
        }
        
        var urlRequest = URLRequest(url: baseUrl)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
