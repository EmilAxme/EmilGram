import Foundation

final class ImagesListService {
    //MARK: - Notification
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    //MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}
    
    //MARK: - Properties
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    
    //MARK: - Functions
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
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    completion(.success(newPhotos))
                case .failure(let error):
                    if let error = error as? NetworkError {
                        handleNetworkError(error, service: "[ImagesListService.fetchPhotosNextPage]", completion: completion)
                    } else {
                        print("[ImagesListService.fetchPhotosNextPage]: Error - Неизвестная ошибка: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let httpMethod = isLiked ? "POST" : "DELETE"
        
        guard let baseUrl = Constants.defaultAPIBaseURL?.appendingPathComponent("/photos/\(photoId)/like") else {
            print("Ошибка: невозможно создать baseURL")
            completion(.failure(NSError(domain: "ImagesListService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(oAuth2TokenStorage.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let self else { return }
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let oldPhoto = self.photos[index]
                let newPhoto = Photo(
                    id: oldPhoto.id,
                    size: oldPhoto.size,
                    createdAt: oldPhoto.createdAt,
                    welcomeDescription: oldPhoto.welcomeDescription,
                    thumbImageURL: oldPhoto.thumbImageURL,
                    largeImageURL: oldPhoto.largeImageURL,
                    isLiked: !oldPhoto.isLiked
                )
                self.photos[index] = newPhoto
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            }
            
            completion(.success(()))
        }
        task.resume()
    }
    
    func removePhotosFromDisk() {
        photos.removeAll()
    }
    
    //MARK: - Private Functions
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
        urlRequest.setValue("Bearer \(oAuth2TokenStorage.token ?? "")", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
}

