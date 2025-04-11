import Foundation

// MARK: - ENUM
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// MARK: - Extension's
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[data(for:)]: Network Error - код ошибки \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[data(for:)]: urlRequstError - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[data(for:)]: urlSessionError - неизвестная ошибка, нет данных и нет error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
                    print(prettyData)
                           
                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    } else {
                        print("❌ Не удалось преобразовать отформатированный JSON в строку")
                    }
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    let responseString = String(data: data, encoding: .utf8) ?? "nil"
                    print("[objectTask]: Ошибка декодирования - \(error.localizedDescription), Данные: \(responseString)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask]: Ошибка при получении данных - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}

// MARK: - Handle function
func handleNetworkError<T>(
    _ error: NetworkError,
    service: String,
    fallbackToken: String? = nil,
    completion: @escaping (Result<T, Error>) -> Void
) {
    DispatchQueue.main.async {
            switch error {
            case .httpStatusCode(let statusCode):
                print("\(service): NetworkError.httpStatusCode - код \(statusCode)")

                if statusCode == 400, let token = fallbackToken as? T {
                    print("\(service): NetworkError.httpStatusCode - ошибка, но токен сохранен \(token)")
                    completion(.success(token))
                    return
                }

                let statusError = NSError(
                    domain: "HTTPError",
                    code: statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера: \(statusCode)"]
                )
                completion(.failure(statusError))

            case .urlRequestError(let requestError):
                print("\(service): NetworkError.urlRequestError - \(requestError.localizedDescription)")
                completion(.failure(requestError))

            case .urlSessionError:
                let noDataError = NSError(
                    domain: "NoData",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"]
                )
                print("\(service): NetworkError.urlSessionError - Нет данных в ответе")
                completion(.failure(noDataError))
            }
        }
}
