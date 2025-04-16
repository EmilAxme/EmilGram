import Foundation
import UIKit

final class AlertPresenter {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)

        if let secondTitle = model.secondButtonText {
            let secondAction = UIAlertAction(title: secondTitle, style: .default) { _ in
                model.secondCompletion?()
            }
            alert.addAction(secondAction)
        }
        delegate?.present(alert, animated: true)
    }
}
