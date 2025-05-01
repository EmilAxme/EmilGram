import UIKit

struct AlertModel {
    // MARK: - Public Properties
    let title: String
    let message: String?
    let buttonText: String
    let secondButtonText: String?
    var completion: (() -> Void)? = nil
    var secondCompletion: (() -> Void)? = nil
}
