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
        
        //check local app have user Photo.
        let userEmail = UserDefaults.standard
        let email = userEmail.string(forKey: "email")
        
        guard let emailChange = email else {
            print("user photo emeil change fial.")
            return nil
        }
        let fileNameFirst = emailChange.split(separator: "@")
        let filePhotoName = "\(fileNameFirst[0]).jpg"
        
        let fileManager = FileManager.default
        let filePath = NSHomeDirectory() + filePhotoName
        let exist = fileManager.fileExists(atPath: filePath)
        
        guard exist == false else {
            print("********** user photo in local app. **********")
            return nil
        }
        
        let photoFileURL = self.fileDocumentsPath(fileName: filePhotoName)
        //if have photo do file change data
        if let imageData = try? Data(contentsOf: photoFileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    //MARK: downLoad user photo.
    func downLoadUserPhoto() {
        var recodeArry :[String:Int]!
        
        //check local app have user Photo.
        let userEmail = UserDefaults.standard
        let email = userEmail.string(forKey: "email")

        guard let emailChange = email else {
            print("user photo emeil change fial.")
            return
        }
        let fileNameFirst = emailChange.split(separator: "@")
        
        let fileManager = FileManager.default
        let filePath = NSHomeDirectory() + "\(fileNameFirst[0]).jpg"
        let exist = fileManager.fileExists(atPath: filePath)
        
        guard exist == false else {
            print("********** user photo in local app. **********")
            return
        }
        
        //check server have user Photo(by MySQL).
        //Post PHP(get user login data).
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Account_Check_UserPhoto.php?photofile=\(fileNameFirst[0])") {

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("uesr login load data URL Session error \(e)")
                    return
                }
                guard let jsData = data else {
                    return
                }
                //let reCode = String(data: jsData, encoding: .utf8)
                //print(reCode!)
                let decoder = JSONDecoder()
                do {
                    recodeArry = try decoder.decode([String:Int].self, from: jsData)

                    //DownLoad user Photo.
                    if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Accoount_Upload_UserPhoto/\(fileNameFirst[0]).jpg") {
                        let request = URLRequest(url: url)
                        let session = URLSession.shared
                        let task = session.dataTask(with: request) { (data, response, error) in
                            if let e = error {
                                print("erroe \(e)")
                            }
                            if let data = data {
                                let image = UIImage(data: data)
                                //write file
                                if let imageData = image?.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
                                    do{
                                        let filePath = self.fileDocumentsPath(fileName: "\(fileNameFirst[0]).jpg")
                                        try imageData.write(to: filePath, options: [.atomicWrite])
                                    }catch {
                                        print("uer photo fiel save is eror : \(error)")
                                    }
                                }
                            }
                        }
                        task.resume()
                    }

                } catch {
                    print("user Photo select json error : \(error)")
                }
            }
            task.resume()
        }
    }
    
    
    
    
}


