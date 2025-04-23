import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlet's
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Static property
    static let reuseIdentifier = "ImageListCell"
    weak var delegate: ImagesListCellDelegate?
//    var isShimmering = false
    
    // MARK: - Functions
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "LikeButtonActive") : UIImage(named: "LikeButton")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}
