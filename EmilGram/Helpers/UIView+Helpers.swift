import UIKit

extension UIView {
    func addToView(_ subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
    }
}
