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
    
    //MARK: func - file dictory URL.
    func fileDocumentsPath(fileName :String) -> URL {
        //建立照片路徑，存的位置，string轉URL一定要用fileURLWithPath
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let filePath = documents.appendingPathComponent(fileName)
        return filePath
    }
    
    //MARK: func - user Photo fiel read.
    func userPhotoRead() -> UIImage? {
        //check UserDefaults have forKey: "userPhotoName".
        let userPhotofile = UserDefaults.standard
        guard let userPhotofileName = userPhotofile.string(forKey: "userPhotoName") else {
            print("********** user is not user Photo. **********")
            return nil
        }
        let photoFileURL = self.fileDocumentsPath(fileName: userPhotofileName)
        //if have photo do file change data
        if let imageData = try? Data(contentsOf: photoFileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    
}


