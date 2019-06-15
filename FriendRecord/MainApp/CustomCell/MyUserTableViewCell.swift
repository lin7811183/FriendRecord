import UIKit

class MyUserTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imageUserPhoto: UIImageView!
    @IBOutlet weak var showLB: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
//    override func layoutSubviews() {
////        self.imageUserPhoto.layer.cornerRadius = self.imageUserPhoto.bounds.height / 2
////        self.imageUserPhoto.clipsToBounds = true
//        //self.imageUserPhoto.layer.borderWidth = 1
//        //self.imageUserPhoto.layer.masksToBounds = false
//        //self.imageUserPhoto.layer.borderColor = UIColor.black.cgColor
//        //self.imageUserPhoto.layer.cornerRadius = 0.5 * self.imageUserPhoto.bounds.size.width
//        //self.imageUserPhoto.clipsToBounds = true
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
