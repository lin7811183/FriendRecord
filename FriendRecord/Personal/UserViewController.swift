import UIKit
import Photos
import MobileCoreServices

class UserViewController: UIViewController {
    
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userTF: UITextView!
    @IBOutlet weak var UserGenderLB: UILabel!
    @IBOutlet weak var userBfLB: UILabel!
    @IBOutlet weak var userPhotoBT: UIButton!
    @IBOutlet weak var editUserTF_BT: UIButton!
    @IBOutlet weak var userTableView: UITableView!
    
    var isUserFTType = false
    
    //var userRecordData = [Record]()
    var tableArray = [TableStruct]()
    
    var uploadArry :[String:Bool]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = UserDefaults.standard
        
        let uesrDataNickName = userData.string(forKey: "nickname")
        //self.userNickNameLB.text = uesrDataNickName
        
        let userDataGender = userData.string(forKey: "gender")
        self.UserGenderLB.text = userDataGender
        
        let userDataBf = userData.string(forKey: "bf")
        self.userBfLB.text = userDataBf
        
        self.userView.layer.cornerRadius = 10
        self.userView.layer.masksToBounds = true
//        self.userView.backgroundColor = UIColor.lightGray
        self.userView.backgroundColor = UIColor(displayP3Red: 192/220, green: 192/220, blue: 192/220, alpha: 0.5)
        
        self.userTF.isEditable = false
        self.userTF.isSelectable = false
        //self.userTF.layer.borderColor = UIColor.black.cgColor
        //self.userTF.layer.borderWidth = 1.0
        self.userTF.layer.cornerRadius = 5.0
        self.userTF.delegate = self
        
        self.userTableView.dataSource = self
        self.userTableView.delegate = self
        
        self.navigationItem.title = uesrDataNickName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //check local app have user Photo.
        let userEmail = UserDefaults.standard
        guard let emailHead = userEmail.string(forKey: "emailHead") else {
            return
        }
        
        let exist = Manager.shared.checkFile(fileName: "\(emailHead).jpg")
        
        if exist != true {
            self.userPhotoBT.layer.cornerRadius = 0.5 * self.userPhotoBT.bounds.size.width
            self.userPhotoBT.clipsToBounds = true
            self.userPhotoBT.setImage(UIImage(named: "userPhotoDefault.png"), for: .normal)
        } else {
            self.userPhotoBT.layer.cornerRadius = 0.5 * self.userPhotoBT.bounds.size.width
            self.userPhotoBT.clipsToBounds = true
            self.userPhotoBT.setImage(Manager.shared.userPhotoRead(jpg: emailHead), for: .normal)
        }
        
        //DownLoadUserRecordPen.
        Manager.delegateUser = self
        Manager.shared.downLoadUserLocalRecordPen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("self.tableArray clear.")
        self.tableArray.removeAll()
    }
    
    /*------------------------------------------------------------ Function ------------------------------------------------------------*/
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
        Manager.recordDataUser.removeAll()
        Manager.recordData.removeAll()
    }
    
    //MARK: func - Edit UserFT
    @IBAction func editUserFT(_ sender: Any) {
        if self.isUserFTType == false {
            self.editUserTF_BT.setImage(UIImage(named: "pen.png"), for: .normal)
            self.userTF.backgroundColor = UIColor.gray
            self.userTF.isSelectable = true
            self.userTF.isEditable = true
            self.isUserFTType = true
        } else {
            self.editUserTF_BT.setTitleColor(UIColor.black, for: .normal)
            self.editUserTF_BT.setImage(UIImage(named: ""), for: .normal)
            self.userTF.backgroundColor = UIColor.white
            self.editUserTF_BT.setTitle("編輯", for: .normal)
            self.userTF.isSelectable = false
            self.userTF.isEditable = false
            self.isUserFTType = false
        }
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

extension UserViewController :UITableViewDataSource ,UITableViewDelegate {
    //MARK: Protocol - tableView - UITableViewDataSource.
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableArray[section].isOpen! == true {
            return 2
        } else {
            return 1
        }
        //return self.userRecordData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.userTableView.dequeueReusableCell(withIdentifier: "userrecordCell", for: indexPath) as! MyUserRecordTableViewCell
//
//        cell.goodSumLB.text = "\(Int(self.userRecordData[indexPath.row].goodSum ?? 0.0))"
//        cell.messageSumLB.text = "\(Int(self.userRecordData[indexPath.row].messageSum ?? 0.0))"
//
//
//
//        cell.selectionStyle = .none//讓選取顏色不會出現
        
        if indexPath.row == 0 {
            let cell = self.userTableView.dequeueReusableCell(withIdentifier: "userrecordCell", for: indexPath) as! MyUserRecordTableViewCell
            cell.goodSumLB.text = "\(Int(self.tableArray[indexPath.section].main.goodSum ?? 0.0))"
            cell.messageSumLB.text = "\(Int(self.tableArray[indexPath.section].main.messageSum ?? 0.0))"
            return cell
        } else {
            let cell = self.userTableView.dequeueReusableCell(withIdentifier: "userrecordCell2", for: indexPath) as! MyUserRecord2TableViewCell
            cell.dateLB.text = self.tableArray[indexPath.section].sub.recordDate
            cell.mainLB.text = self.tableArray[indexPath.section].sub.recordText
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableArray[indexPath.section].isOpen == true {
            self.tableArray[indexPath.section].isOpen = false
            let section = IndexSet.init(integer: indexPath.section)
            self.userTableView.reloadSections(section, with: .fade)
        } else {
            self.tableArray[indexPath.section].isOpen = true
            let section = IndexSet.init(integer: indexPath.section)
            self.userTableView.reloadSections(section, with: .fade)
        }
    }
}

extension UserViewController :ManagerDelegateUser {
    //MARK: Protocol - CodeManagerDelegateUser
    func finishDownLoadUserRecordPen() {
        print("ManagerDelegate = finishDownLoadUserPhoto")
        
        DispatchQueue.main.async {
//            self.userRecordData = Manager.userLocalRecordPen
            
            for i in 0 ..< Manager.userLocalRecordPen.count {
                var newData = TableStruct()
                newData.isOpen = false
                newData.main = Manager.userLocalRecordPen[i]
                newData.sub = Manager.userLocalRecordPen[i]
                
                self.tableArray.append(newData)
            }
            print("tableArray: \(self.tableArray.count)")
//            print("userRecordData: \(self.userRecordData.count)")
            self.userTableView.reloadData()
        }
    }
}

extension UserViewController :UITextViewDelegate {
    //MARK: Protocol - textFiel Delegate.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.userTF.textColor = UIColor.black
        return true
    }
}

/*------------------------------------------------------------ Protcol. ------------------------------------------------------------*/
extension UserViewController :UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    //MARK: Protocol - CodeUIImagePickerControllerDelegate , UINavigationControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        Manager.shared.thumbmailImage(image: image)
        
        //new user Photo.
        let userDataDefault = UserDefaults.standard
        userDataDefault.bool(forKey: "isUserPhoto")
        userDataDefault.set(true , forKey: "isUserPhoto")
        
        //check is login and registered.
        let userEmail = UserDefaults.standard
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
