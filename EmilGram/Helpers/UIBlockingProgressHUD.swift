import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    // MARK: - Static Functions/Properties

    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
}
