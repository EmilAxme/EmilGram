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
    // MARK: - Property's
    weak var delegate: ImagesListCellDelegate?
}
