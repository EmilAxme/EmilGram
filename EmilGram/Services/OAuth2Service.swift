import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var authToken: String?
    
    func fetchOAuthToken(code: String,  completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Services", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не валидный реквест"])))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
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
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                    
    
                    completion(.success(tokenResponse.accessToken))
                    
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
                        
                        if statusCode == 400, let token = OAuth2TokenStorage.shared.token {
                            print("Несмотря на 400, токен уже сохранён: \(token)")
                            DispatchQueue.main.async {
                                completion(.success(token))
                            }
                            return
                        }
                        
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
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest? {
        let baseUrl = Constants.defaultBaseURL?.appendingPathComponent("oauth/token")
        guard let baseUrl else {
            print("Ошибка: невозможно создать baseURL")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            print("Ошибка: не удалось создать URLComponents из \(baseUrl)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code)
        ]
        
        guard let url = urlComponents.url else {
            print("Ошибка: не удалось получить URL из URLComponents: \(urlComponents)")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        print("Успешно")
        return urlRequest
    }
    
    

}
