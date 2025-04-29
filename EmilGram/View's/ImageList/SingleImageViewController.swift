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
        didSet {
                guard isViewLoaded else { return }
                guard let image = singleImage.image else { return }
                singleImage.image = image
                rescaleAndCenterImageInScrollView(image: image)
            }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        guard let image = image else { return }
        singleImage.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Private Functions
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        singleImage.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        
        let xInset = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let yInset = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
    }
}

// MARK: - Extension's
extension SingleImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImage
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    private func centerImage() {
        let visibleSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let xInset = max(0, (visibleSize.width - contentSize.width) / 2)
        let yInset = max(0, (visibleSize.height - contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
    }
}
