import UIKit
protocol MyRecordTableViewCell2Delegate {
    func updateIsGood(isGoodType :Bool ,cell :UITableViewCell)
}

class MyRecord2TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var goodSumLB: UILabel!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var messageSumLB: UILabel!
    @IBOutlet weak var recordPenGoodBT: UIButton!
    
    var RecordID :Double!
    var Good_user :String?
    var delegate :MyRecordTableViewCell2Delegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: func - Give Good For Record Pen.
    @IBAction func giveRecordPenGood(_ sender: Any) {
        print("giveRecordPenGood")
        
        var data = Manager.recordData.filter{ $0.recordID == self.RecordID }
        
        if data.first?.Good_user != nil {
            print("user is cancel good.")
            self.upLoadRecordPenGood()
            self.delegate.updateIsGood(isGoodType: false,cell: self)
        } else {
            print("user give good.")
            self.upLoadRecordPenGood()
            self.delegate.updateIsGood(isGoodType: true,cell: self)
        }
    }
    
    //MARK: func - upLoadRecordPenGood
    func upLoadRecordPenGood() {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/RecordPen/Record_Pen_Good.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let userData = UserDefaults.standard
            guard let email = userData.string(forKey: "email") else {
                return
            }
            let param = "recordId=\(self.RecordID!)&usermail=\(email)"
            print("\(param)")
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
                guard let jsonData = data else {
                    return
                }
            }
            task.resume()
        }
    }
    
}
