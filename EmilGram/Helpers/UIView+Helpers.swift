import UIKit

extension UIView {
    // MARK: - Functions
    func addToView(_ subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
    }
}
