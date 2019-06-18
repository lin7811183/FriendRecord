import UIKit

class MyRecordTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mainLB: UILabel!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var sendRecordDateLB: UILabel!
    @IBOutlet weak var sendUserNameLB: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
