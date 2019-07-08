import UIKit

protocol LeaveMessageViewControllerDelegate {
    func updateMessageSum()
}

class LeaveMessageViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var messageSendImage: UIImageView!
    @IBOutlet weak var userMessageView: UIView!
    
    @IBOutlet weak var playerBT: UIButton!
    @IBOutlet weak var userBT: UIButton!
    
    var formVC :Int!
    var dataArray :[Record]!
    
    var userBTCenterPoint :CGPoint!
    var test = false
    
    var messageTVData :[Message] = []
    var tmp :[Message] = []
    
    var recordId :Int!
    var messageIndexPath :IndexPath!
    
    var messageSumType :Int!
    
    var delegate :LeaveMessageViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = UserDefaults.standard
        guard let emailHead = userData.string(forKey: "emailHead") else {
            return
        }
        self.messageSendImage.image = Manager.shared.userPhotoRead(jpg: emailHead)
        self.messageSendImage.layer.cornerRadius = self.messageSendImage.bounds.height / 2
        
        self.playerBT.layer.cornerRadius = self.playerBT.bounds.height / 2
        
        
        self.userBTCenterPoint =  self.userBT.center
        self.userBT.center = self.playerBT.center
        
        self.messageTableView.dataSource = self
        self.messageTableView.delegate = self
        
        self.messageTF.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.downLoadMessage()
        
        if self.formVC == 0 {
            print("form MainAppVC.")
            self.dataArray = Manager.recordData
            
        } else {
            print("form UserVC.")
            self.dataArray = Manager.userLocalRecordPen
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.delegate.updateMessageSum()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.playerBT.frame = CGRect(x: self.playerBT.frame.minX, y: self.playerBT.frame.minY, width: self.playerBT.frame.size.width, height: self.playerBT.frame.size.height)
    }
    /*------------------------------------------------------------ Function. ------------------------------------------------------------*/

    @IBAction func playerMemu(_ sender: UIButton) {
        if self.test == false {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.userBT.alpha = 1
                
                self.userBT.center = self.userBTCenterPoint
                
                self.test = true
                })
        } else {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.userBT.alpha = 0
                
                self.userBT.center  = self.playerBT.center
                
                self.test = false
            })
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
        print("\(self.messageTVData.count)")
        if self.messageTVData.count == 0 {
            print("目前尚未有人留言")
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

extension LeaveMessageViewController :UITextFieldDelegate {
    //MARK: Protocol - UITextFiel Delegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //return close keyboard.
        textField.resignFirstResponder()
        return true
    }
    //touch textfiel begin.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.mainView.translatesAutoresizingMaskIntoConstraints = false//一定要加，不加會有錯，關閉舊有的Layout機制(autoreizing mask)
        self.userMessageView.frame.size.height = 100
        self.userMessageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: 0).isActive = true
        self.userMessageView.leftAnchor.constraint(equalTo: self.mainView.leftAnchor, constant: 0).isActive = true
        self.userMessageView.rightAnchor.constraint(equalTo: self.mainView.rightAnchor, constant: 0).isActive = true //往回縮
    }
    //touch textfiel end.
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.mainView.translatesAutoresizingMaskIntoConstraints = false//一定要加，不加會有錯，關閉舊有的Layout機制(autoreizing mask)
        self.userMessageView.frame.size.height = 86
        self.userMessageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: 0).isActive = true
        self.userMessageView.leftAnchor.constraint(equalTo: self.mainView.leftAnchor, constant: 0).isActive = true
        self.userMessageView.rightAnchor.constraint(equalTo: self.mainView.rightAnchor, constant: 0).isActive = true //往回縮

    }
}
