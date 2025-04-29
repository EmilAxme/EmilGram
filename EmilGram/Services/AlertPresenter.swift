import Foundation
import UIKit

final class AlertPresenter {
    // MARK: - Property
    weak var delegate: UIViewController?
    
    
    // MARK: - Init
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    // MARK: - Func
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
