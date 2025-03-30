import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private enum profileResultsConstants {
        static let unsplashGetProfileResultsURLString = "https://api.unsplash.com/me"
    }

    
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
                        let profileResult = try decoder.decode(ProfileResponseResult.self, from: data)
                        let profile = Profile(from: profileResult)
                        self.profile = profile
                        completion(.success(profile))
                        
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
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
