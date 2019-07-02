import UIKit

class MyUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageUserPhoto: UIImageView!
    @IBOutlet weak var showLB: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
