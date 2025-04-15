import Foundation

final class ImagesListService {
    //MARK: - Notification
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    //MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}
    
    //MARK: - Property's
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    //MARK: - Function's
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        if task != nil {
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makeImageListRequest(pageNumber: nextPage) else {
            completion(.failure(NSError(domain: "ImagesListService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }

        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { Photo(from: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    completion(.success(newPhotos))
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
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
        }
        self.task = task
        task.resume()
    }
    
    private func makeImageListRequest(pageNumber: Int) -> URLRequest? {
        guard var components = URLComponents(string: Constants.defaultAPIBaseURL?.appendingPathComponent("/photos").absoluteString ?? "") else {
                print("Ошибка: невозможно создать URLComponents")
                return nil
            }

            components.queryItems = [
                URLQueryItem(name: "page", value: "\(pageNumber)")
            ]

            guard let url = components.url else {
                print("Ошибка: невозможно создать URL из компонентов")
                return nil
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if isLiked {
            let baseUrl = Constants.defaultBaseURL?.appendingPathComponent("/photos/\(photoId)/like")
            guard let baseUrl else {
                print("Ошибка: невозможно создать baseURL")
                return
            }
            guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
                print("Ошибка: не удалось создать URLComponents из \(baseUrl)")
                return
            }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: Constants.accessKey)
            ]
            guard let url = urlComponents.url else {
                print("Ошибка: не удалось получить URL из URLComponents: \(urlComponents)")
                return
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
        } else {
            let baseUrl = Constants.defaultBaseURL?.appendingPathComponent("/photos/\(photoId)/like")
            guard let baseUrl else {
                print("Ошибка: невозможно создать baseURL")
                return
            }
            guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
                print("Ошибка: не удалось создать URLComponents из \(baseUrl)")
                return
            }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: Constants.accessKey)
            ]
            guard let url = urlComponents.url else {
                print("Ошибка: не удалось получить URL из URLComponents: \(urlComponents)")
                return
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
        }
        // Поиск индекса элемента
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            // Текущий элемент
           let photo = self.photos[index]
           // Копия элемента с инвертированным значением isLiked.
            let newPhoto = Photo(from: <#PhotoResult#>)
            // Заменяем элемент в массиве.
            self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
        }
    }
    
}
