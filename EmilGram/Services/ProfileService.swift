import Foundation

final class ProfileService {
    //MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    //MARK: - Set var
    private(set) var profile: Profile?
    
    //MARK: - Properties
    private var task: URLSessionTask?
    private var lastToken: String?
    
    //MARK: - ENUM
    private enum profileResultsConstants {
        static let unsplashGetProfileResultsURLString = "https://api.unsplash.com/me"
    }

    //MARK: - Functions
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
                
        guard lastToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastToken = token
        
        guard let request = makeUserProfileRequest() else {
            completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResponseResult, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    if let error = error as? NetworkError {
                        handleNetworkError(error, service: "[ProfileService.fetchOAuthToken]", completion: completion)
                    } else {
                        print("[ProfileService.fetchOAuthToken]: Error - Неизвестная ошибка: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
            self.task = nil
            self.lastToken = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeUserProfileRequest() -> URLRequest? {
        let baseUrl = Constants.defaultAPIBaseURL?.appendingPathComponent("me")
        guard let baseUrl else {
            print("Ошибка: невозможно создать baseURL")
            return nil
        }
        
        var urlRequest = URLRequest(url: baseUrl)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "asd")", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
