import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    //MARK: - Properties
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private var authToken: String?
    
    //MARK: - Function's
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Services", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не валидный реквест"])))
            return
        }

        let task = urlSession.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            
            switch result {
            case .success(let tokenResponse):
                OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))

            case .failure(let error):
                if let error = error as? NetworkError {
                    handleNetworkError(error, service: "[OAuth2Service.fetchOAuthToken]", fallbackToken: OAuth2TokenStorage.shared.token, completion: completion)
                } else {
                    print("[OAuth2Service.fetchOAuthToken]: Error - Неизвестная ошибка: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }

        self.task = task
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
        return urlRequest
    }
}
