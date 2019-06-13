import UIKit

class UserPhotoViewController: UIViewController {
    
    
    @IBOutlet weak var bigUserPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bigUserPhoto.image = Manager.shared.userPhotoRead()
        
    }
    
    //MARK: func - back to UserVC.
    @IBAction func backUserPersonal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
