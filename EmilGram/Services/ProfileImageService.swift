import Foundation
 
final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private var profileService = ProfileService.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
                
        guard let request = makeUserProfileRequest(username: username) else {
            completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let data):
                    
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Ответ сервера: \(jsonString)")
                    } else {
                        print("Ответ сервера не удалось преобразовать в строку")
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let profileImageResult = try decoder.decode(UserResult.self, from: data)
                        let avatarURL = profileImageResult.profileImage.small
                        self.avatarURL = avatarURL
                        completion(.success(avatarURL))
                    } catch {
                        completion(.failure(error))
                        print("Ошибка декодирования")
                    }
                case .failure(let error):
                    if let error = error as? NetworkError {
                        switch error {
                        case .httpStatusCode(let statusCode):
                            print("Ошибка сервера: \(statusCode)")
                            
                            let statusError = NSError(domain: "HTTPError",
                                                      code: statusCode,
                                                      userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера: \(statusCode)"])
                            DispatchQueue.main.async {
                                completion(.failure(statusError))
                            }
                            
                        case .urlRequestError(let requestError):
                            print("Сетевая ошибка: \(requestError.localizedDescription)")
                            
                            DispatchQueue.main.async {
                                completion(.failure(requestError))
                            }
                            
                        case .urlSessionError:
                            let noDataError = NSError(domain: "No data",
                                                      code: -1,
                                                      userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])
                            print("Нет данных в ответе")
                            
                            DispatchQueue.main.async {
                                completion(.failure(noDataError))
                            }
                        }
                    } else {
                        print("Неизвестная ошибка: \(error.localizedDescription)")
                        
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
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
