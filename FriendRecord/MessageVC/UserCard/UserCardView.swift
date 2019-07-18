import UIKit

class UserCardView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBF: UILabel!
    @IBOutlet weak var userGender: UILabel!
    @IBOutlet weak var userGenderImage: UIImageView!
    @IBOutlet weak var userSend: UITextView!
    
    @IBOutlet weak var Test: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // we're going to do stuff here.
        Bundle.main.loadNibNamed("UserCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
}
