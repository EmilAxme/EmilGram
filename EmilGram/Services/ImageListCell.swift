import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlet's
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Static Properties
    static let reuseIdentifier = "ImageListCell"
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Functions
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "LikeButtonActive") : UIImage(named: "LikeButton")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}
