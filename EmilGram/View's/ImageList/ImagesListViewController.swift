import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func showError(title: String, message: String?, buttonText: String, secondButtonText: String?, completion: (() -> Void)?, secondCompletion: (() -> Void)?)
    func reloadAnimatedTableView(oldCount: Int, newCount: Int)
    func presentFullScreenImage(at index: Int?)
}

final class ImagesListViewController: UIViewController {
    var presenter: ImagesListPresenterProtocol?

    @IBOutlet var tableView: UITableView!
    
    private var alert: AlertPresenter?
    private let shimmerService = ShimmerService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        alert = AlertPresenter(delegate: self)
        configureTableView()
        presenter?.viewDidLoad()
    }

    func configureTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func reloadAnimatedTableView(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func showError(title: String, message: String?, buttonText: String, secondButtonText: String?, completion: (() -> Void)? = nil, secondCompletion: (() -> Void)? = nil) {
        let model = AlertModel(title: title, message: message, buttonText: buttonText, secondButtonText: secondButtonText, completion: completion, secondCompletion: secondCompletion)
        alert?.presentAlert(with: model)
    }

    func presentFullScreenImage(at index: Int?) {
        guard let index = index else { return }
        guard let presenter = presenter else { return }
        guard let url = URL(string: presenter.photos[index].largeImageURL) else { return }
        let imageView = UIImageView()
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let imageResult):
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else { return }
                vc.image = imageResult.image
                present(vc, animated: true)
            case .failure:
                self.showError(
                    title: "Что-то пошло не так",
                    message: "Попробовать ещё раз?",
                    buttonText: "Не надо",
                    secondButtonText: "Повторить", completion: nil,
                    secondCompletion: {
                        self.presentFullScreenImage(at: index)
                    }
                )
            }
        }
    }
    
    func configure(_ cell: ImagesListCell, at index: Int) {
        guard let presenter = presenter else { return }
        let viewModel = presenter.viewModel(for: index)

        cell.dateLabel.text = viewModel.dateText

        cell.cellImage.kf.indicatorType = .activity
        shimmerService.addShimmer(to: cell.cellImage)
        cell.cellImage.kf.setImage(with: viewModel.imageURL, placeholder: UIImage(named: "placeholder")) { [weak self] _ in
            self?.shimmerService.removeShimmerLayers()
        }

        let likeImageName = viewModel.isLiked ? "LikeButtonActive" : "LikeButton"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
        cell.likeButton.accessibilityIdentifier = "like button"
        
        cell.delegate = self
        
    }
}
