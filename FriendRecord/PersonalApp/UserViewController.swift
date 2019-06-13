import UIKit
import Photos
import MobileCoreServices

class UserViewController: UIViewController {
    
    //@IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNickNameLB: UILabel!
    @IBOutlet weak var UserGenderLB: UILabel!
    @IBOutlet weak var userBfLB: UILabel!
    @IBOutlet weak var userPhotoBT: UIButton!
    
    var uploadArry :[String:Bool]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = UserDefaults.standard
        
        let uesrDataNickName = userData.string(forKey: "nickname")
        self.userNickNameLB.text = uesrDataNickName
        
        let userDataGender = userData.string(forKey: "gender")
        self.UserGenderLB.text = userDataGender
        
        let userDataBf = userData.string(forKey: "bf")
        self.userBfLB.text = userDataBf
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //check local app have user Photo.
        let userEmail = UserDefaults.standard
        let emailHead = userEmail.string(forKey: "emailHead")

        let fileManager = FileManager.default
        let filePath = NSHomeDirectory()+"/Documents/"+"\(emailHead!).jpg"
        let exist = fileManager.fileExists(atPath: filePath)

        guard exist == true else {
            print("********** user photo not in local app(userVC). **********")
            //self.userImageView.image = UIImage(named: "userPhotoDefault.png")
            
            self.userPhotoBT.layer.cornerRadius = 0.5 * self.userPhotoBT.bounds.size.width
            self.userPhotoBT.clipsToBounds = true
            self.userPhotoBT.setImage(UIImage(named: "userPhotoDefault.png"), for: .normal)
            return
        }
        //self.userImageView.image = self.userPhotoRead()
        
        self.userPhotoBT.layer.cornerRadius = 0.5 * self.userPhotoBT.bounds.size.width
        self.userPhotoBT.clipsToBounds = true
        self.userPhotoBT.setImage(Manager.shared.userPhotoRead(), for: .normal)
        
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    //MARK: func - User Photo Look.
    @IBAction func userPhotoLook(_ sender: Any) {
        //let userPhotoVC = self.storyboard?.instantiateViewController(withIdentifier: "userphotoVC") as! UserPhotoViewController
        //self.present(userPhotoVC, animated: true, completion: nil)
    }
    //MARK: func - logout button
    @IBAction func logout(_ sender: Any) {
        //set isLogin key to UserDefaults.
        let loginUserDefault = UserDefaults.standard
        loginUserDefault.set(false , forKey: "isLogin")
        
        //clear userDefault.
        let userDefault = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: userDefault)
        UserDefaults.standard.synchronize()
        print("********** clear userDefault. **********")
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
        print("********** user is logout secure. **********")
    }
    
    //MARK: func - user imaage photo.
    @IBAction func userImagePhoto(_ sender: Any) {
        
        //Prepare imagePicker.
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        
        let photoBT = UIButton(frame: CGRect(x: 90, y: UIScreen.main.bounds.size.height - 160 , width: 64, height: 64))
        photoBT.setTitle("相簿", for:.normal)
        photoBT.titleLabel?.textColor = UIColor.white
        photoBT.addTarget(self, action: #selector(photoLibrary), for: .touchUpInside)
        picker.view.addSubview(photoBT)
        
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
    //MARK: func - get photo library.
    @objc func photoLibrary() {
        
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .photoLibrary
        photoPicker.delegate = self
        self.dismiss(animated: true, completion: nil)
        self.present(photoPicker, animated: true)
    }
}

extension UserViewController :UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        Manager.shared.thumbmailImage(image: image)
        
        //check is login and registered.
        let userEmail = UserDefaults.standard
        //read userdefault is login or registered?
        let emailHead = userEmail.string(forKey: "emailHead")
        guard let emailChange = emailHead else {
            print("user photo emeil change fail(imagePickerController).")
            return
        }

        let fileName = "\(emailChange).jpg"
//
//        let filePath = self.fileDocumentsPath(fileName: fileName)
//
//        //write file
//        if let imageData = image.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
//            do{
//                try imageData.write(to: filePath, options: [.atomicWrite])
//            }catch {
//                print("uer photo fiel save is eror : \(error)")
//            }
//        }
        
//        //save user photo name by UserDefaults.
//        let userPhotoName = UserDefaults.standard
//        userPhotoName.string(forKey: "userPhotoName")
//        userPhotoName.set("\(fileName)" , forKey: "userPhotoName")
        
        self.dismiss(animated: true, completion: nil)//關閉imagePickController
        
        
        //Upload user Photo to server.
        //上傳地址
        let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Accoount_Upload_UserPhoto.php?userphotofileName=\(emailChange)")
        
        //請求
        var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        
        //上傳數據流
        let documents =  NSHomeDirectory()+"/Documents/"+fileName
        //print(documents)
        let recordData = try! Data(contentsOf: URL(fileURLWithPath: documents))
        
        let uploadTask = session.uploadTask(with: request, from: recordData) {
            (data:Data?, response:URLResponse?, error:Error?) -> Void in
            
            //上傳完畢後
            if error != nil{
                print("Uoload user Photo error : \(error)")
            }else{
                //let str = String(data: data!, encoding: .utf8)
                //print("上傳完畢：\n\(str!)")
                let jsDecoder = JSONDecoder()
                do {
                    self.uploadArry = try jsDecoder.decode([String:Bool].self, from: data!)
                }catch {
                    print("Upload uer Photo jsDecoder error :\(error)")
                }
            }
        }
        uploadTask.resume()
    }
    
}
