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
    @IBOutlet weak var userTabBar: UINavigationItem!
    @IBOutlet weak var userBT: UIButton!
    
    var isUserFTType = false
    
    //var userRecordData = [Record]()
    var tableArray = [TableStruct]()
    
    var uploadArry :[String:Bool]!
    
    var pushRecordID :Double!
    var pushIndex :IndexPath!
    
    var fromUserVC = 0
    var reocrdPenEmail :String!
    
    var isPiayer = false
    //建立AudioRecorder元件
    var recordPlayer :AVAudioPlayer?
    var recordIndexPath :IndexPath!
    var oldRecordIndexPath :IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.fromUserVC == 0 {
            let userData = UserDefaults.standard
            
            let uesrDataNickName = userData.string(forKey: "nickname")
            //self.userNickNameLB.text = uesrDataNickName
            
            let userDataGender = userData.string(forKey: "gender")
            self.UserGenderLB.text = userDataGender
            
            let userDataBf = userData.string(forKey: "bf")
            self.userBfLB.text = userDataBf

            //self.navigationItem.title = uesrDataNickName
            self.userBT.setImage(UIImage(named: "down"), for: .normal)
            self.userBT.setTitle(uesrDataNickName, for: .normal)
        } else {
            
        }
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.editUserTF_BT.setTitle("編輯", for: .normal)
        
        if self.fromUserVC == 0 {
            //check local app have user Photo.
            let userData = UserDefaults.standard
            guard let emailHead = userData.string(forKey: "emailHead") else {
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
            guard let email = userData.string(forKey: "email") else {
                return
            }
            Manager.shared.downLoadUserLocalRecordPen(email: email)
            Manager.shared.downLoadUserPresent(email: email
            )
        } else {
            //DownLoadUserRecordPen.
            Manager.delegateUser = self
            Manager.shared.downLoadUserLocalRecordPen(email: self.reocrdPenEmail!)
            Manager.shared.downLoadUserPresent(email: self.reocrdPenEmail!)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableArray.removeAll()
        self.stopOldRecordMuice()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.stopOldRecordMuice()
    }
    /*------------------------------------------------------------ Function ------------------------------------------------------------*/
    //MARK: func - Stop Old Record Muice.
    func stopOldRecordMuice() {
        //Stop old Record pen muice.
        if self.isPiayer == true {
            if let indexPath = self.oldRecordIndexPath {
                print("user is out UserVC.")
                let oldcurrentCell = self.userTableView.cellForRow(at: indexPath) as! MyUserRecordTableViewCell
                oldcurrentCell.playerBT.setImage(UIImage(named: "Star"), for: .normal)
                self.recordPlayer?.stop()
                self.isPiayer = false
            }
        }
    }
    //MARK: func - User Photo Look.
    @IBAction func userPhotoLook(_ sender: Any) {
        //let userPhotoVC = self.storyboard?.instantiateViewController(withIdentifier: "userphotoVC") as! UserPhotoViewController
        //self.present(userPhotoVC, animated: true, completion: nil)
    }
    //MARK: func - User More
    @IBAction func userMore(_ sender: Any) {
        let moreAlert = UIAlertController(title: "知音", message: "更多功能", preferredStyle: .actionSheet)
        let appPresentAction = UIAlertAction(title: "知音導覽", style: .default) { (action) in
            let AppPresent = self.storyboard?.instantiateViewController(withIdentifier: "AppPresnetVC") as! AppPresentViewController
            self.present(AppPresent, animated: true, completion: nil)
        }
        moreAlert.addAction(appPresentAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        moreAlert.addAction(cancelAction)
        self.present(moreAlert, animated: true, completion: nil)
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
            self.editUserTF_BT.setTitle("", for: .normal)
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
            
            let userData = UserDefaults.standard
            let useremail = userData.string(forKey: "email")
            self.uploadUserPresent(email: useremail!, present: self.userTF.text)
            userData.string(forKey: "present")
            userData.set("\(self.userTF.text!)" , forKey: "present")
        }
    }
    
    //MARK: func - user upload present.
    func uploadUserPresent(email :String ,present :String) {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Account_Upload_Present.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let session = URLSession.shared
            let param = "email=\(email)&present=\(present)"
            
            request.httpBody = param.data(using: .utf8)
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
                let reCode = String(data: data!, encoding: .utf8)
                print(reCode!)
            }
            task.resume()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userpush" {
            let cell = sender as! MyUserRecordTableViewCell
            let leavemessageVC = segue.destination as! LeaveMessageViewController
            leavemessageVC.recordId = Int(cell.recordID)
            leavemessageVC.messageIndexPath = cell.recordIndexPath
            leavemessageVC.formVC = 1
            
            leavemessageVC.delegate = self
        }
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
        if indexPath.row == 0 {
            let cell = self.userTableView.dequeueReusableCell(withIdentifier: "userrecordCell", for: indexPath) as! MyUserRecordTableViewCell
            cell.goodSumLB.text = "\(Int(self.tableArray[indexPath.section].main.goodSum ?? 0.0))"
            cell.messageSumLB.text = "\(Int(self.tableArray[indexPath.section].main.messageSum ?? 0.0))"
            
            cell.recordID = self.tableArray[indexPath.section].main.recordID!
            cell.recordIndexPath = indexPath
            
            cell.delegate = self
            
            cell.playerBT.setImage(UIImage(named: "Star"), for: .normal)
            cell.playerBT.addTarget(self, action: #selector(player(sender:)), for: .touchUpInside)
            cell.playerBT.tag = indexPath.section
            
            cell.selectionStyle = .none//讓選取顏色不會出現
            
//            cell.layer.borderWidth = 1.0
//            cell.layer.borderColor = UIColor.gray.cgColor
            
            return cell
        } else {
            let cell = self.userTableView.dequeueReusableCell(withIdentifier: "userrecordCell2", for: indexPath) as! MyUserRecord2TableViewCell
            cell.dateLB.text = self.tableArray[indexPath.section].sub.recordDate
            cell.mainLB.text = self.tableArray[indexPath.section].sub.recordText
            
            cell.selectionStyle = .none//讓選取顏色不會出現
            
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
    
    @objc func player(sender :UIButton){
        
        if self.isPiayer == true {
            let oldcurrentCell = self.userTableView.cellForRow(at: self.oldRecordIndexPath) as! MyUserRecordTableViewCell
            oldcurrentCell.playerBT.setImage(UIImage(named: "Star"), for: .normal)
            
            guard let bt = sender as? UIButton  else {
                return
            }
            let row = bt.tag
            let indexPath = IndexPath(row: 0, section: row)
            self.recordIndexPath = indexPath
            self.oldRecordIndexPath = indexPath
            let currentCell = self.userTableView.cellForRow(at: indexPath) as! MyUserRecordTableViewCell
            currentCell.playerBT.setImage(UIImage(named: "Star"), for: .normal)
            
            //Record stop Player.
            self.recordPlayer?.stop()
            print("********** Stop player Record. **********")
            
            self.isPiayer = false
        } else {
            guard let bt = sender as? UIButton  else {
                return
            }
            let row = bt.tag
            let indexPath = IndexPath(row: 0, section: row)
            self.recordIndexPath = indexPath
            self.oldRecordIndexPath = indexPath
            let currentCell = self.userTableView.cellForRow(at: indexPath) as! MyUserRecordTableViewCell
            
            let filePathURL = Manager.shared.fileDocumentsPath(fileName: self.tableArray[indexPath.section].main.recordFileName!)
            //Play Record.
            self.recordPlayer = try? AVAudioPlayer(contentsOf: filePathURL)
            self.recordPlayer?.numberOfLoops = 0
            self.recordPlayer?.prepareToPlay()
            self.recordPlayer?.delegate = self
            
            //Create Audio Session.
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.playback)
            
            //Record Player.
            self.recordPlayer?.play()
            print("********** Star player Record. **********")
            
            currentCell.playerBT.setImage(UIImage(named: "Stop"), for: .normal)
            
            self.isPiayer = true
        }
    }
}

extension UserViewController :AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            let currentCell = self.userTableView.cellForRow(at: self.recordIndexPath)  as! MyUserRecordTableViewCell
            self.recordPlayer?.stop()
            print("********** Stop player Record. **********")
            currentCell.playerBT.setImage(UIImage(named: "Star"), for: .normal)
            self.isPiayer = false
        }
    }
}

extension UserViewController :ManagerDelegateUser {
    //MARK: Protocol - CodeManagerDelegateUser
    func finishDownLoadUserRecordPen() {
        print("ManagerDelegate = finishDownLoadUserPhoto")
        
        DispatchQueue.main.async {
            for i in 0 ..< Manager.userLocalRecordPen.count {
                var newData = TableStruct()
                newData.isOpen = false
                newData.main = Manager.userLocalRecordPen[i]
                newData.sub = Manager.userLocalRecordPen[i]
                
                self.tableArray.append(newData)
            }
            print("tableArray: \(self.tableArray.count)")
            //self.userTableView.reloadData()
            UIView.transition(with: self.userTableView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.userTableView.reloadData() })
        }
    }
    func finishDownLoadUserPresent(preenst: String) {
        DispatchQueue.main.async {
            self.userTF.text = preenst
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

extension UserViewController :MyUserRecordTableViewCellDelegate {
    func userPushIndexPath(cell: UITableViewCell) {
        print("MyUserRecordTableViewCellDelegate - userPushIndexPath")
        self.performSegue(withIdentifier: "userpush", sender: cell)
    }
}

extension UserViewController :LeaveMessageViewControllerDelegate {
    func updateMessageSum() {
        print("LeaveMessageViewControllerDelegate - updateMessageSum")
        self.userTableView.reloadData()
    }
}
