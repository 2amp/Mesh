import UIKit

extension UIViewController {
    func showAlert(title title: String, message: String) {
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}