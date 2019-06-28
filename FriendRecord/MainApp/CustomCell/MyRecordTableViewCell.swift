import UIKit

protocol MyRecordTableViewCellDelegate {
    func updateIsGood(isGoodType :Bool ,cell :UITableViewCell)
}

class MyRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainLB: UILabel!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var sendRecordDateLB: UILabel!
    @IBOutlet weak var sendUserNameLB: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var goodSumLB: UILabel!
    @IBOutlet weak var messageSumLB: UILabel!
    
    @IBOutlet weak var recordPenGoodBT: UIButton!
    var RecordID :Double!
    var email :String!
    var isGood :Bool!
    
    var delegate :MyRecordTableViewCellDelegate!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK: func - Give Good For Record Pen.
    @IBAction func giveRecordPenGood(_ sender: Any) {
    
        if self.isGood == nil {
            print("\(self.RecordID!) , \(self.isGood)")
            self.isGood = true
        } else if self.isGood == false{
            print("\(self.RecordID!) , \(self.isGood!) , 取消棒！！！")
            self.delegate.updateIsGood(isGoodType: self.isGood! ,cell:  self)
            self.isGood = true
        } else {
            print("RecordID:\(self.RecordID!),\(self.isGood!), 給棒！！！")
            upLoadRecordPenGood()
            self.delegate.updateIsGood(isGoodType: self.isGood! ,cell: self)
            self.isGood = false
            
        }
    }
    
    //MARK: func - upLoadRecordPenGood
    func upLoadRecordPenGood() {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/RecordPen/Record_Pen_Good.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "recordId=\(self.RecordID!)&usermail=\(self.email!)"
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
