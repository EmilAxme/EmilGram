import UIKit
import Kingfisher

protocol ImagesListPresenterProtocol: AnyObject {
    var photosCount: Int { get }
    var photos: [Photo] { get }
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func willDisplayCell(at index: Int)
    func cellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func didTapLike(on cell: ImagesListCell)
    func viewModel(for index: Int) -> PhotoCellViewModel 
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }

    var photosCount: Int {
        photos.count
    }

    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let oldCount = photos.count
            self.photos = self.imagesListService.photos
            if oldCount != self.photos.count {
                self.view?.reloadAnimatedTableView(oldCount: oldCount, newCount: self.photos.count)
            }
        }

        imagesListService.fetchPhotosNextPage { _ in }
    }

    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func viewModel(for index: Int) -> PhotoCellViewModel {
        let photo = photos[index]
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let imageURL = URL(string: photo.thumbImageURL)
        return PhotoCellViewModel(dateText: dateText, imageURL: imageURL, isLiked: photo.isLiked)
    }

    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            imagesListService.fetchPhotosNextPage { _ in }
        }
    }

    func cellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func didTapLike(on cell: ImagesListCell) {
        guard let indexPath = (view as? ImagesListViewController)?.tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()

        imagesListService.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                case .failure:
                    self.view?.showError(title: "Не удалось изменить лайк",
                                         message: "Попробуйте снова",
                                         buttonText: "Ок",
                                         secondButtonText: nil,
                                         completion: nil,
                                         secondCompletion: nil)
                }
            }
        }
    }
}
