import UIKit

class MyMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageUserImage: UIImageView!
    @IBOutlet weak var userLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
