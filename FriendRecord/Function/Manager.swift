import Foundation
import UIKit

class Manager :UIViewController {
    
    static let shared = Manager()
    
//    private init() {
//
//    }
    
    //MARK: func - dismissKeyboard.
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
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
    func okAlter(vc: UIViewController, title: String, message: String) {
        let alter = UIAlertController(title: title, message: message,preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alter.addAction(okAction)
        vc.present(alter, animated: true, completion: nil)
    }
    
    //MARK: func - file dictory URL.
    func fileDocumentsPath(fileName :String) -> URL {
        //建立照片路徑，存的位置，string轉URL一定要用fileURLWithPath
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let filePath = documents.appendingPathComponent(fileName)
        return filePath
    }
    
    //MARK: func - check file in app.
    func checkFile(fileName :String) -> Bool {
        let fileManager = FileManager.default
        let filePath = NSHomeDirectory()+"/Documents/"+fileName
        let exist = fileManager.fileExists(atPath: filePath)
        return exist
    }
    
    //MARK: func - user Photo file read.
    func userPhotoRead() -> UIImage? {
        
        //check local app have user Photo.
        let userEmail = UserDefaults.standard
        //read userdefault is login or registered?
        let emailHead = userEmail.string(forKey: "emailHead")
        
        guard let emailChange = emailHead else {
            print("user photo emeil change fail(userPhotoRead).")
            return nil
        }
        
        let exist = self.checkFile(fileName: "\(emailChange).jpg")
        
        guard exist == true else {
            print("********** user photo is no local app. **********")
            return nil
        }
        
        let photoFileURL = self.fileDocumentsPath(fileName: "\(emailChange).jpg")
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
        let emailHead = userEmail.string(forKey: "emailHead")
        
        guard let emailChange = emailHead else {
            print("user photo emeil change fail(downLoadUserPhoto).")
            return
        }
        
        let exist = self.checkFile(fileName: "\(emailChange).jpg")
        
        guard exist == true else {
            print("********** user photo not in local app. **********")
            //check server have user Photo(by MySQL).
            //Post PHP(get user login data).
            if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Account_Check_UserPhoto.php?photofile=\(emailChange)") {
                
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
                    //print(reCode)
                    let decoder = JSONDecoder()
                    do {
                        recodeArry = try decoder.decode([String:Int].self, from: jsData)
                        //print("\(recodeArry.first!.value)")
                        guard recodeArry.first!.value == 0 else {
                            print("user is not upload userPhoto to server.")
                            return
                        }
                        
                        //DownLoad user Photo.
                        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Accoount_Upload_UserPhoto/\(emailChange).jpg") {
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
                                            let filePath = self.fileDocumentsPath(fileName: "\(emailChange).jpg")
                                            //check is User Photo.
                                            let userEmail = UserDefaults.standard
                                            let emailHead = userEmail.string(forKey: "emailHead")
                                            guard let emailChange = emailHead else {
                                                print("user photo emeil change fail(NaVC).")
                                                return
                                            }
                                            let exist = Manager.shared.checkFile(fileName: "\(emailChange).jpg")
                                            if exist == false {
                                                let userDataDefault = UserDefaults.standard
                                                userDataDefault.bool(forKey: "isUserPhoto")
                                                userDataDefault.set(true , forKey: "isUserPhoto")
                                            }
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
                        print("user Photo select to Mysql json error : \(error)")
                    }
                }
                task.resume()
            }
            return
        }
        print("********** user photo in local app. **********")
    }
    
    //MARK: func - save thumbmailImage
    func thumbmailImage(image :UIImage) -> UIImage? {
        
        //設定縮圖大小
        let thumbnailSize = CGSize(width: 900 ,height: 900)
        //找出目前螢幕的scale
        let scale = UIScreen.main.scale
        //產生畫布
        UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
        //計算長寬要縮圖比例
        let width = thumbnailSize.width / image.size.width
        let height = thumbnailSize.height / image.size.height
        let ratio = max(width,height)
        let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio)
        //在畫圖行前 切圓形
//        let circle = UIBezierPath(ovalIn: CGRect(x: 0,y: 0,width: thumbnailSize.width,height: thumbnailSize.height))
//        circle.addClip()
        image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,width: imageSize.width,height: imageSize.height))
        //取得畫布上的圖
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        //關掉畫布
        UIGraphicsEndImageContext()
        
        let userEmail = UserDefaults.standard
        //read userdefault is login or registered?
        let emailHead = userEmail.string(forKey: "emailHead")
        let fileName = "\(emailHead!).jpg"
        
        let filePath = self.fileDocumentsPath(fileName: fileName)
        
        //write file
        if let imageData = smallImage?.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
            do{
                try imageData.write(to: filePath, options: [.atomicWrite])
            }catch {
                print("uer photo fiel save is eror : \(error)")
            }
        }
        return smallImage
    }
}
