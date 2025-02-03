import UIKit

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    var image: UIImage?
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet fileprivate var singleImage: UIImageView!{
        didSet{
            guard isViewLoaded else { return }
            singleImage.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        singleImage.image = image
    }
}

extension SingleImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImage
    }
}
