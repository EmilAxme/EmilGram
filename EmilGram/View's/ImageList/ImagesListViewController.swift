//
//  ViewController.swift
//  EmilGram
//
//  Created by Emil on 25.01.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    private var imageListServiceObserver: NSObjectProtocol?
    private var alert: AlertPresenter?
    private var shimmerAdded = false
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imagesListService = ImagesListService.shared
//    let photosName: [String] = Array(0..<20).map{ "\($0)"}
    
    var photos: [Photo] = []
    var animationLayers = Set<CALayer>()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alert = AlertPresenter(delegate: self)

        if imagesListService.photos.isEmpty && !shimmerAdded {
            shimmerAdded = true
        }

        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateTableViewAnimated()
        }
        
        imagesListService.fetchPhotosNextPage { _ in }
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    //MARK: - Private functions
    func addShimmer(to view: UIView, cornerRadius: CGFloat = 0) {
        if view.layer.sublayers?.contains(where: { $0.name == "shimmerLayer" }) == true {
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = "shimmerLayer" // ✅ имя слоя
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
    
    func removeShimmer(from view: UIView) {
        view.layer.sublayers?.removeAll(where: { $0.name == "shimmerLayer" })
    }
    
    //MARK: - Function's
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage { _ in
            }
        }
    }
    
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
        
    
}
