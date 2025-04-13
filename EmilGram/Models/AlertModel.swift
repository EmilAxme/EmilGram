import UIKit

struct AlertModel {
    // MARK: - Public Properties
    let title: String
    let message: String?
    let buttonText: String
    var completion: (() -> Void)? = nil
}
