import UIKit

extension UIView {
    // MARK: - Function
    func addToView(_ subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
    }
}
