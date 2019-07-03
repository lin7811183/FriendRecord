import UIKit

class LeaveMessageViewController: UIViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var messageSendImage: UIImageView!
    
    var messageTVData :[Message] = []
    
    var recordId :Int!
    var messageIndexPath :IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userEmail = UserDefaults.standard
        guard let emailHead = userEmail.string(forKey: "emailHead") else {
            return
        }
        self.messageSendImage.image = Manager.shared.userPhotoRead(jpg: emailHead)
        self.messageSendImage.layer.cornerRadius = self.messageSendImage.bounds.height / 2
        
        self.messageTableView.dataSource = self
        self.messageTableView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /*------------------------------------------------------------ Function. ------------------------------------------------------------*/
    @IBAction func messageSend(_ sender: Any) {
        if Manager.recordData[self.messageIndexPath.row].messageSum == 0.0 {
            print("1")
            self.messageTVData.removeAll()
            
            let newMessage = Message()
            newMessage.message = self.messageTF.text
            print("\(newMessage.message)")
            
            self.messageTVData.insert(newMessage, at: 0)
            self.messageTableView.reloadData()
        } else {
            print("2")
            let newMessage = Message()
            newMessage.message = self.messageTF.text
            self.messageTVData.insert(newMessage, at: 0)
            self.messageTableView.reloadData()
        }
    }
    
}

/*------------------------------------------------------------ Protocol ------------------------------------------------------------*/
extension LeaveMessageViewController :UITableViewDataSource, UITableViewDelegate {
    //MARK: Protocol - tableView UITableViewDataSource.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Manager.recordData[self.messageIndexPath.row].messageSum == 0.0 {
            return 1
        } else {
            return self.messageTVData.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.messageTableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MyMessageTableViewCell
        
        if Manager.recordData[self.messageIndexPath.row].messageSum == 0.0 {
            cell.messageLB.text = "目前尚未有人留言!"
        }
        
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
        self.messageTableView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
    }
    //touch textfiel end.
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.messageTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
