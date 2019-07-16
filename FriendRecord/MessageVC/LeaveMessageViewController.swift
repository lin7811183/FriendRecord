import UIKit
import AVKit

protocol LeaveMessageViewControllerDelegate {
    func updateMessageSum()
}

class LeaveMessageViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var messageSendImage: UIImageView!
    @IBOutlet weak var userMessageView: UIView!
    @IBOutlet weak var messageSendView: UIView!
    
    @IBOutlet weak var moreBT: UIButton!
    @IBOutlet weak var listenBT: UIButton!
    @IBOutlet weak var addFriendBT: UIButton!
    @IBOutlet weak var lookUserCard: UIButton!
    
    var addBTCenterPoint :CGPoint!
    var listenBTCenterPoint :CGPoint!
    var lookUserCardBTCenterPoint :CGPoint!
    
    var formVC :Int!
    var dataArray :[Record]!
    
    var test = false
    
    var messageTVData :[Message] = []
    var tmp :[Message] = []
    
    var recordId :Int!
    var messageIndexPath :IndexPath!
    var recordSendUser :String!
    var recorduserNickName :String!
    
    var messageSumType :Int!
    
    var delegate :LeaveMessageViewControllerDelegate!
    
    var isFriendArray :[MessageIsFriend]!
    var isFriend :Bool!
    
    var isPlayer = false
    //建立AudioRecorder元件
    var recordPlayer :AVAudioPlayer?
    var recordFileName :String!
    
    var userCardView = UIView()
    var backView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = UserDefaults.standard
        guard let emailHead = userData.string(forKey: "emailHead") else {
            return
        }
        self.messageSendImage.image = Manager.shared.userPhotoRead(jpg: emailHead)
        self.messageSendImage.layer.cornerRadius = self.messageSendImage.bounds.height / 2
        
        self.moreBT.layer.cornerRadius = self.moreBT.frame.height / 2
        
        self.listenBT.layer.cornerRadius = self.moreBT.frame.height / 2
//        self.userBT.layer.borderWidth = 1
//        self.userBT.layer.borderColor = UIColor.black.cgColor
        
        self.listenBTCenterPoint =  self.listenBT.center
        self.listenBT.center = self.moreBT.center
        
        self.addBTCenterPoint = self.addFriendBT.center
        self.addFriendBT.center = self.moreBT.center
        
        self.lookUserCardBTCenterPoint = self.lookUserCard.center
        self.lookUserCard.center = self.moreBT.center
        
        self.messageTableView.dataSource = self
        self.messageTableView.delegate = self
        
        self.messageTF.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.downLoadMessage()
        self.downLoadMessageIsFriend()
        
        if self.formVC == 0 {
            print("form MainAppVC.")
            self.dataArray = Manager.recordData
            Manager.shared.loadUserCardData(email: self.recordSendUser)

        } else {
            print("form UserVC.")
            self.dataArray = Manager.userLocalRecordPen
            self.moreBT.isHidden = true
            self.addFriendBT.isHidden = true
            self.listenBT.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.delegate.updateMessageSum()
        }
        // Stop Record Pen Player.
        self.listenBT.setImage(UIImage(named: "listner"), for: .normal)
        self.recordPlayer?.stop()
        print("********** Stop player Record. **********")
        self.isPlayer = false
        
        self.isFriendArray.removeAll()
        self.dataArray.removeAll()
        self.messageTVData.removeAll()
        Manager.userCardData.removeAll()
        print("********** Clear Array. **********")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.moreBT.frame = CGRect(x: self.moreBT.frame.minX, y: self.moreBT.frame.minY, width: self.moreBT.frame.size.width, height: self.moreBT.frame.size.height)
    }
    /*------------------------------------------------------------ Function. ------------------------------------------------------------*/
    //MARK: func - player Menu.
    @IBAction func playerMemu(_ sender: UIButton) {
        if self.test == false {
            UIView.animate(withDuration: 0.3, animations: {
                self.listenBT.alpha = 1
                self.addFriendBT.alpha = 1
                self.lookUserCard.alpha = 1
                
                self.listenBT.center = self.listenBTCenterPoint
                self.addFriendBT.center = self.addBTCenterPoint
                self.lookUserCard.center = self.lookUserCardBTCenterPoint
                
                self.test = true
                })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.listenBT.alpha = 0
                self.addFriendBT.alpha = 0
                self.lookUserCard.alpha = 0
                
                self.listenBT.center  = self.moreBT.center
                self.addFriendBT.center = self.moreBT.center
                self.lookUserCard.center = self.moreBT.center
                
                self.test = false
            })
        }
    }
    //MARK: func - Add to Friend.
    @IBAction func addToFriend(_ sender: UIButton) {

        if self.isFriend != true {
            if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Account_Add_Friend.php") {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                let userData = UserDefaults.standard
                guard let email = userData.string(forKey: "email") else {
                    return
                }
                let param = "email=\(email)&Femail=\(self.recordSendUser!)&Fname=\(self.recorduserNickName!)"
                print("\(param)")
                request.httpBody = param.data(using: .utf8)
                
                let session = URLSession.shared
                let task = session.dataTask(with: request) { (data, response, error) in
                    if let e = error {
                        print("erroe \(e)")
                    }
                    let reCode = String(data: data!, encoding: .utf8)
                    print(reCode!)
                }
                task.resume()
                DispatchQueue.main.async {
                    Manager.shared.okAlter(vc: self, title: "已成為您的知音", message: "可在好友清單確認")
                    self.addFriendBT.setImage(UIImage(named: "AddFriend"), for: .normal)
                }
            }
        }
        else {
            Manager.shared.okAlter(vc: self, title: "已經是你的知音摟", message: "")
        }
    }
    //MARK: func - Look user card.
    @IBAction func lookUserCard(_ sender: Any) {
        self.backView.frame = self.view.frame
        self.backView.tag = 997
        self.backView.backgroundColor = UIColor.black
        backView.alpha = 0.3
        self.view.addSubview(self.backView)
        
        let userCardView = UserCardView()
        userCardView.tag = 998
        userCardView.frame = CGRect(x: 12.5 ,y: (self.navigationController?.navigationBar.frame.size.height)! + 100, width:self.userCardView.frame.size.width, height: self.userCardView.frame.size.height)
        userCardView.mainView.layer.cornerRadius = 5.0
        let imageName = Manager.shared.emailChangeHead(email: self.recordSendUser)
        userCardView.userImage.image = Manager.shared.userPhotoRead(jpg: imageName)
        userCardView.userImage.layer.cornerRadius = userCardView.userImage.bounds.height / 2
        userCardView.userName.text = Manager.userCardData.first?.nickname
        userCardView.userBF.text = Manager.userCardData.first?.bf
        userCardView.userGender.text = Manager.userCardData.first?.gender
        userCardView.userSend.text = Manager.userCardData.first?.presentation
        UIView.transition(with: self.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {self.view.addSubview(userCardView)}, completion: nil)//加入此視窗
        
        let cancelBT = UIButton()
        cancelBT.tag = 999
        cancelBT.frame = CGRect(x: self.view.center.x - 25, y: (self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)!) - 100, width: 50, height: 50)
        cancelBT.setImage(UIImage(named: "cencel"), for: .normal)
        cancelBT.addTarget(self, action: #selector(dissMissUserCardView), for: .touchUpInside)
        UIView.transition(with: self.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {self.view.addSubview(cancelBT)}, completion: nil)//加入此視窗
    }
    // diss Miss UserCardView BT
    @objc func dissMissUserCardView() {
        let back = self.view.viewWithTag(997)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {back?.removeFromSuperview()}, completion: nil)
        let card = self.view.viewWithTag(998)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {card?.removeFromSuperview()}, completion: nil)
        let cancel = self.view.viewWithTag(999)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {cancel?.removeFromSuperview()}, completion: nil)
    }
    //MARK: func - Record Playe
    @IBAction func RecordPlayer(_ sender: Any) {
        if self.isPlayer == false {
            self.listenBT.setImage(UIImage(named: "listnering"), for: .normal)
            
            let filePathURL = Manager.shared.fileDocumentsPath(fileName: self.recordFileName)
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
            self.isPlayer = true
        } else {
            self.listenBT.setImage(UIImage(named: "listner"), for: .normal)
            
            self.recordPlayer?.stop()
            print("********** Stop player Record. **********")
            self.isPlayer = false
        }
    }
    //MARK: func - Message send to Reocrd pen.
    @IBAction func messageSend(_ sender: Any) {
        var sum = self.dataArray[self.messageIndexPath.row].messageSum
        
        let userData = UserDefaults.standard
        let email = userData.string(forKey: "email")
        let userNickName = userData.string(forKey: "nickname")
        
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW") // 設定地區(台灣)
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei") // 設定時區(台灣)
        
        if sum == 0.0 {
            
            sum! += 1.0
            self.dataArray[self.messageIndexPath.row].messageSum = sum
            
            self.messageTVData.removeAll()
            
            let newMessage = Message()
            newMessage.recordID = Double(self.recordId)
            newMessage.messageUser = email!
            newMessage.messageNickName = userNickName
            newMessage.message = self.messageTF.text
            newMessage.penDate = dateFormatter.string(from: nowDate)
            self.messageTVData.append(newMessage)
            
            self.upLoadMessage(email: email!, nickName: userNickName!, message: newMessage.message!)
            self.messageTableView.reloadData()
            
            self.messageTF.text = ""
            self.messageTF.resignFirstResponder()
            
        } else {
            sum! += 1.0
            self.dataArray[self.messageIndexPath.row].messageSum = sum
            
            let newMessage = Message()
            newMessage.recordID = Double(self.recordId)
            newMessage.messageUser = email!
            newMessage.messageNickName = userNickName
            newMessage.message = self.messageTF.text

            newMessage.penDate = dateFormatter.string(from: nowDate)
            self.messageTVData.append(newMessage)
            
            self.upLoadMessage(email: email!, nickName: userNickName!, message: newMessage.message!)
            self.messageTableView.reloadData()
            
            self.messageTF.text = ""
            self.messageTF.resignFirstResponder()
        }
    }
    //MARK: func - UpLoad Message to MySQL.
    func upLoadMessage(email :String, nickName :String, message :String) {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/message/UpLoad_Message.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "recordID=\(self.recordId!)&email=\(email)&nickName=\(nickName)&message=\(message)"
            request.httpBody = param.data(using: .utf8)

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
            }
            task.resume()
        }
    }
    //MARK: func - DownLoad Message.
    func downLoadMessage() {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/message/DownLoad_Message.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "recordID=\(self.recordId!)"
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
                guard let jsonData = data else {
                    return
                }
                let reCode = String(data: data!, encoding: .utf8)
                print(reCode!)
                let decoder = JSONDecoder()
                do {
                    self.messageTVData = try decoder.decode([Message].self, from: jsonData)//[Note].self 取得Note陣列的型態
                    
                    DispatchQueue.main.async {
                        print("messageTVData count:\(self.messageTVData.count)")
                        self.messageTableView.reloadData()
                    }
                } catch {
                    print("error while parsing json \(error)")
                }
            }
            task.resume()
        }
        
    }
    
    //MARK: func - DownLoad Message isFriend?.
    func downLoadMessageIsFriend() {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/message/DownLoad_Message_IsFriend.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "recordID=\(self.recordId!)"
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
                guard let jsonData = data else {
                    return
                }
                let reCode = String(data: data!, encoding: .utf8)
                print(reCode!)
                let decoder = JSONDecoder()
                do {
                    self.isFriendArray = try decoder.decode([MessageIsFriend].self, from: jsonData)//[Note].self 取得Note陣列的型態
                    print("isFriendArray count : \(self.isFriendArray.count)")
                    DispatchQueue.main.async {
                        let userData = UserDefaults.standard
                        if let userEmail = userData.string(forKey: "email") {
                            for i in 0 ..< self.isFriendArray.count {
                                // Check This Record Pen in Me!?
                                if self.isFriendArray[i].recordSendUser! != userEmail {
                                    if let friendName = self.isFriendArray[i].isFriend {
                                        if friendName == userEmail {
                                            print("********** This Record Pen is My Friend Pen. **********")
                                            self.addFriendBT.setImage(UIImage(named: "AddFriend"), for: .normal)
                                            self.isFriend = true
                                            break
                                        } else {
                                            print("********** This Record Pen is not My Friend Pen. **********")
                                            self.addFriendBT.setImage(UIImage(named: "isNoFriend"), for: .normal)
                                            self.isFriend = false
                                        }
                                    } else {
                                        print("********** This Record Pen is not Friend. **********")
                                        self.addFriendBT.setImage(UIImage(named: "isNoFriend"), for: .normal)
                                        self.isFriend = false
                                    }
                                } else {
                                    print("********** This Record Pen is me. **********")
                                    self.isFriend = true
                                }
                            }
                        }
                    }
                } catch {
                    print("error while parsing json \(error)")
                }
            }
            task.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "seeuser" {
//            let userVC = segue.destination as! UserViewController
//            userVC.fromUserVC = 1
//            userVC.reocrdPenEmail = self.recordEmail!
//        }
    }
}

/*------------------------------------------------------------ Protocol ------------------------------------------------------------*/
extension LeaveMessageViewController :UITableViewDataSource, UITableViewDelegate {
    //MARK: Protocol - tableView UITableViewDataSource.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.messageTVData.count == 0 {
            return 1
        } else {
            return self.messageTVData.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.messageTableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MyMessageTableViewCell
        if self.messageTVData.count == 0 {
            cell.messageLB.text = "目前尚未有人留言!"
        } else {
            let data = messageTVData[indexPath.row]
        
            cell.messageUserImage.image = Manager.shared.userPhotoRead(jpg: Manager.shared.emailChangeHead(email: data.messageUser!))
            cell.messageUserImage.layer.cornerRadius = cell.messageUserImage.bounds.height / 2
            
            cell.userLB.text = data.messageNickName!
            cell.messageLB.text = data.message
            
            let time = Manager.shared.dateChange(date: data.penDate!)
            cell.messageTimeLB.text = time
        }
        cell.selectionStyle = .none
        
        self.messageTableView.rowHeight = cell.messageLB.bounds.height + 50
        return cell
    }
    //MARK: Protocol -  tableViewe UITableViewDelegate.
}

extension LeaveMessageViewController :AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            self.listenBT.setImage(UIImage(named: "listner"), for: .normal)
            self.recordPlayer?.stop()
            print("********** Stop player Record. **********")
            self.isPlayer = false
        }
    }
}

extension LeaveMessageViewController :UITextFieldDelegate {
    //touch textfiel begin.
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.messageTableView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
//        self.mainView.translatesAutoresizingMaskIntoConstraints = false//一定要加，不加會有錯，關閉舊有的Layout機制(autoreizing mask)
//        self.userMessageView.frame.size.height = 150
//        print("Begin前\(self.mainView.frame.size.height)")
//        self.mainView.frame.size.height = self.mainView.frame.size.height - (self.tabBarController?.tabBar.frame.size.height)!
//        print("Begin後\(self.mainView.frame.size.height)")
//        self.userMessageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: 0).isActive = true
//        self.userMessageView.leftAnchor.constraint(equalTo: self.mainView.leftAnchor, constant: 0).isActive = true
//        self.userMessageView.rightAnchor.constraint(equalTo: self.mainView.rightAnchor, constant: 0).isActive = true //往回縮

    }
    //touch textfiel end.
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.messageTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        self.mainView.translatesAutoresizingMaskIntoConstraints = false//一定要加，不加會有錯，關閉舊有的Layout機制(autoreizing mask)
//        self.userMessageView.frame.size.height = 86
//        print("Did前\(self.mainView.frame.size.height)")
//        self.mainView.frame.size.height = self.mainView.frame.size.height + (self.tabBarController?.tabBar.frame.size.height)!
//        print("Did後\(self.mainView.frame.size.height)")
//        self.userMessageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: 0).isActive = true
//        self.userMessageView.leftAnchor.constraint(equalTo: self.mainView.leftAnchor, constant: 0).isActive = true
//        self.userMessageView.rightAnchor.constraint(equalTo: self.mainView.rightAnchor, constant: 0).isActive = true //往回縮
    }
}
