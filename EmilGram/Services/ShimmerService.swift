import UIKit

final class ShimmerService {
    
    static let shared = ShimmerService()
    private init() {}
    
    private var animationLayers = Set<CALayer>()
    
    func addShimmer(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.8, 1]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmer")
    }
    
    func removeShimmerLayers() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
