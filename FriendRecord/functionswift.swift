import Foundation
import UIKit

extension UIViewController {
    //MARK: func - dismissKeyboard.
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //MARK: func - UIDatePicker dateFormat.
    func datapickerformat(datePicker :UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let outputdata = dateFormatter.string(from: datePicker.date)
        return outputdata
    }
    
    //MARK: func - UIAlert.
    func okAlter(title: String, message: String) {
        let alter = UIAlertController(title: title, message: message,preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
        }
        alter.addAction(okAction)
        self.present(alter, animated: true, completion: nil)
    }
    
}


