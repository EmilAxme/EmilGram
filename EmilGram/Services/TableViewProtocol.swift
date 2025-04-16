import UIKit
import Kingfisher
import ProgressHUD

extension ImagesListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: photos[indexPath.row].largeImageURL) else { return }

        UIBlockingProgressHUD.show()
        
        let imageView = UIImageView()
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let imageResult):
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                guard let singleImageVC = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else {
                    assertionFailure("Не найден контроллер")
                    return
                }
                singleImageVC.image = imageResult.image
                present(singleImageVC, animated: true)
            case .failure:
                self.showError(
                    title: "Что-то пошло не так",
                    message: "Попробовать ещё раз?",
                    buttonText: "Не надо",
                    secondButtonText: "Повторить",
                    secondCompletion: {
                        self.tableView(tableView, didSelectRowAt: indexPath)
                    }
                )
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        var cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = photos[indexPath.row].thumbImageURL
        let url = URL(string: image)
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: .none
        )
        
        let likeImage = photos[indexPath.row].isLiked ? UIImage(named: "LikeButtonActive") : UIImage(named: "LikeButton")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        cell.dateLabel.text = "\(dateFormatter.string(from: Date()))"
        cell.delegate = self 
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLiked: !photo.isLiked) {[weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UIBlockingProgressHUD.dismiss()
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    print(self.photos[indexPath.row].isLiked)
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    self.showError(title: "Не удалось изменить лайк", message: "Попробуйте снова", buttonText: "Okay", secondButtonText: nil)
                }
            }
        }
    }
}
    

