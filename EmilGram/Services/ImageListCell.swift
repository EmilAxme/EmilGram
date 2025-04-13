import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlet's
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    // MARK: - Static property
    static let reuseIdentifier = "ImageListCell"
}
