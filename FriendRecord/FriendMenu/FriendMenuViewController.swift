import UIKit

class FriendMenuViewController: UIViewController {
    
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet var mainView: UIView!
    
    var friendListData = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.friendTableView.dataSource = self
        self.friendTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //DownLoad Friend List.
        let userData = UserDefaults.standard
        guard let userEmail = userData.string(forKey: "email") else {
            print("********** FriendVC get user email error. **********")
            return
        }
        self.downLoadFriendList(email: userEmail)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*------------------------------------------------------------ Functions. ------------------------------------------------------------*/
    //MARK: func - disMiss FriendVC.
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Protocol - DownLoad User Friend List.
    func downLoadFriendList(email :String) {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Account_Load_Friend_List.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "email=\(email)"
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
                    self.friendListData = try decoder.decode([Friend].self, from: jsonData)//[Note].self 取得Note陣列的型態
                    print("Friend List :\(self.friendListData.count)")
                    DispatchQueue.main.async {
                        self.friendTableView.reloadData()
                    }
                } catch {
                    print("error while parsing json \(error)")
                }
            }
            task.resume()
        }
    }
    
}

extension FriendMenuViewController :UITableViewDataSource, UITableViewDelegate {
    //MARK: Protocol - TableView DataSource.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.friendListData.count == 0 {
            return 1
        } else {
           return self.friendListData.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendTableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! MyFriendTableViewCell
        
        if self.friendListData.count == 0 {
            cell.userNickName.text = "目前0位知音~"
            cell.isOnlineImage.image = nil
            cell.userImage.image = nil
            cell.selectionStyle = .none//讓選取顏色不會出現
        } else {
            cell.userNickName.text = self.friendListData[indexPath.row].friendNickName
            
            let fileName = Manager.shared.emailChangeHead(email: self.friendListData[indexPath.row].friendEmail!)
            cell.userImage.image = Manager.shared.userPhotoRead(jpg: fileName)
            cell.userImage.layer.cornerRadius = cell.userImage.bounds.height / 2
            
            cell.isOnlineImage.isHidden = false
            
            if self.friendListData[indexPath.row].isLogin != 0 {
                cell.isOnlineImage.image = UIImage(named: "online")
            } else {
                cell.isOnlineImage.image = UIImage(named: "offline")
            }
            cell.selectionStyle = .none//讓選取顏色不會出現
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    //MARK: Protocol - TableView Delegate.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard self.friendListData.count != 0 else {
                print("********** User is no Friens. **********")
                return
            }
            let userEmail = self.friendListData[indexPath.row].userEmail!
            let friendEmail = self.friendListData[indexPath.row].friendEmail!
            Manager.shared.deleteFriend(email: userEmail, friendEmail: friendEmail)
            
            self.friendListData.remove(at: indexPath.row)
            self.friendTableView.reloadData()
        }
    }
}
