import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?
    
    @IBOutlet private var singleImage: UIImageView!{
        didSet{
            guard isViewLoaded else { return }
            singleImage.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleImage.image = image
    }
}
