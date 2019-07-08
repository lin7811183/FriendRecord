import UIKit

protocol MyUserRecordTableViewCellDelegate {
    func userPushIndexPath(cell :UITableViewCell)
}

class MyUserRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var playerBT: UIButton!
    @IBOutlet weak var goodSumLB: UILabel!
    @IBOutlet weak var messageSumLB: UILabel!
    
    var delegate :MyUserRecordTableViewCellDelegate!
    
    var recordID :Double!
    var recordIndexPath :IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func player(_ sender: UIButton) {
    }
    
    
    @IBAction func userMessageSend(_ sender: Any) {
        self.delegate.userPushIndexPath(cell: self)
    }
}
