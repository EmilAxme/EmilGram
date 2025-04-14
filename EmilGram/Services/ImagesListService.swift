//import Foundation
//
//final class ImagesListService {
//    //MARK: - Notification
//    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
//    
//    //MARK: - Singleton
//    static let shared = ImagesListService()
//    private init() {}
//    
//    //MARK: - Property's
//    private(set) var photos: [Photo] = []
//    
//    private var lastLoadedPage: Int?
//    private var task: URLSessionTask?
//    
//    //MARK: - Function's
//    func fetcаhPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
//        assert(Thread.isMainThread)
//        task?.cancel()
//        
//        if task != nil {
//            return
//        }
//
//        let nextPage = (lastLoadedPage ?? 0) + 1
//
//        guard let request = makeImageListRequest(pageNumber: nextPage) else {
//            completion(.failure(NSError(domain: "ImagesListService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
//            return
//        }
//
//        
//        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let photoResults):
//                    let newPhotos = photoResults.map { Photo(from: $0) }
//                    self.photos.append(contentsOf: newPhotos)
//                    self.lastLoadedPage = nextPage
//                    completion(.success(newPhotos))
//                    NotificationCenter.default.post(
//                        name: ImagesListService.didChangeNotification,
//                        object: self
//                    )
//                case .failure(let error):
//                    if let error = error as? NetworkError {
//                        handleNetworkError(error, service: "[ProfileService.fetchOAuthToken]", completion: completion)
//                    } else {
//                        print("[ProfileService.fetchOAuthToken]: Error - Неизвестная ошибка: \(error.localizedDescription)")
//                        completion(.failure(error))
//                    }
//                }
//            }
//            self.task = nil
//        }
//        self.task = task
//        task.resume()
//    }
//    
//    private func makeImageListRequest(pageNumber: Int) -> URLRequest? {
//        guard var components = URLComponents(string: Constants.defaultAPIBaseURL?.appendingPathComponent("/photos").absoluteString ?? "") else {
//                print("Ошибка: невозможно создать URLComponents")
//                return nil
//            }
//
//            components.queryItems = [
//                URLQueryItem(name: "page", value: "\(pageNumber)")
//            ]
//
//            guard let url = components.url else {
//                print("Ошибка: невозможно создать URL из компонентов")
//                return nil
//            }
//        
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
//        return urlRequest
//    }
//}
