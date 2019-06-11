import UIKit
import Photos
import MobileCoreServices

class UserViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNickNameLB: UILabel!
    @IBOutlet weak var UserGenderLB: UILabel!
    @IBOutlet weak var userBfLB: UILabel!
    
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
        self.userImageView.image = self.userPhotoRead()
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    //MARK: func - logout button
    @IBAction func logout(_ sender: Any) {
        //set isLogin key to UserDefaults.
        let loginUserDefault = UserDefaults.standard
        loginUserDefault.set(false , forKey: "isLogin")
        
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
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //check is login and registered.
        let userEmail = UserDefaults.standard
        //read userdefault is login or registered?
        let email = userEmail.string(forKey: "email")
        
        guard let emailChange = email else {
            print("user photo emeil change fial.")
            return
        }
        
        let fileNameFirst = emailChange.split(separator: "@")
        let fileName = "\(fileNameFirst[0]).jpg"
        
        let filePath = self.fileDocumentsPath(fileName: fileName)
        
        //write file
        if let imageData = image.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
            do{
                try imageData.write(to: filePath, options: [.atomicWrite])
            }catch {
                print("uer photo fiel save is eror : \(error)")
            }
        }
        //save user photo name by UserDefaults.
        let userPhotoName = UserDefaults.standard
        userPhotoName.string(forKey: "userPhotoName")
        userPhotoName.set("\(fileName)" , forKey: "userPhotoName")
        
        self.dismiss(animated: true, completion: nil)//關閉imagePickController
    }
    
}
