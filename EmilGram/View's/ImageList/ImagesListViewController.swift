import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    private var imageListServiceObserver: NSObjectProtocol?
    private var alert: AlertPresenter?
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imagesListService = ImagesListService.shared
    let shimmerService = ShimmerService.shared
    
    var photos: [Photo] = []
    var animationLayers = Set<CALayer>()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        alert = AlertPresenter(delegate: self)

        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateTableViewAnimated()
        }
        
        imagesListService.fetchPhotosNextPage { _ in }
        
    }
    
    //MARK: - Functions
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func showError(title: String, message: String?, buttonText: String, secondButtonText: String?, completion: (() -> Void)? = nil, secondCompletion: (() -> Void)? = nil) {
        let errorAlert = AlertModel(title: title,
                                    message: message ?? nil,
                                    buttonText: buttonText, secondButtonText: secondButtonText,
                                    completion: completion, secondCompletion: secondCompletion)
        
        guard let alert else { return }
        
        alert.presentAlert(with: errorAlert)
    }
    
    func loadFullImage(for viewController: SingleImageViewController, url: URL) {
        let imageView = UIImageView()
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let imageResult):
                viewController.image = imageResult.image
            case .failure:
                self.showError(
                    title: "Что-то пошло не так",
                    message: "Попробовать ещё раз?",
                    buttonText: "Не надо",
                    secondButtonText: "Повторить",
                    secondCompletion: {
                        self.loadFullImage(for: viewController, url: url)
                    }
                )
            }
        }
    }
    
    //MARK: - Private Functions
    func configureTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
}
