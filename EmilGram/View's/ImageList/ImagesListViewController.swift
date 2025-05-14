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
     
    
    func addShimmer(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.8, 1]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmer")
    }
    
    func removeShimmerLayers() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    //MARK: - Private Functions
    func configureTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
}
