import UIKit

class UserPhotoViewController: UIViewController {
    
    
    @IBOutlet weak var bigUserPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //record file path URL.
        let recordData = UserDefaults.standard
        let recordDataEmailHead = recordData.string(forKey: "emailHead")
        self.bigUserPhoto.image = Manager.shared.userPhotoRead(jpg: recordDataEmailHead!)
        
    }
    
    //MARK: func - back to UserVC.
    @IBAction func backUserPersonal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
