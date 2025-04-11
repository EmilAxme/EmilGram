import UIKit

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var image: UIImage?
    // MARK: - Actions
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Outlets
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var singleImage: UIImageView!{
        didSet{
            guard isViewLoaded else { return }
            guard let image = singleImage.image else { return }
            singleImage.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = image else { return }
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        singleImage.image = image
        singleImage.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Functions
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        
        
        let xInset = (visibleRectSize.width - newContentSize.width) / 2
        let yInset = (visibleRectSize.height - newContentSize.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: yInset + 200, left: xInset + 200, bottom: yInset + 200, right: xInset + 200)
    }
}

// MARK: Extension's
extension SingleImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImage
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with scale: CGFloat, atContentOffset contentOffset: CGPoint) {
            guard let image = singleImage.image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
}
