import UIKit

class PenViewController: UIViewController {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var mainLB: UILabel!
    @IBOutlet weak var penableView: UITableView!
    
    var selectIndexPath :Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectIndexPath = Manager.indexPath
        print("penVC:\(self.selectIndexPath)")
        //Show Data to UI.
        guard let index = self.selectIndexPath else {
            print("********** get error index. **********")
            return
        }
        let data = Manager.recordData[index]
        let photoName = data.recordSendUser!
        let photoNameChange = photoName.split(separator: "@")
        let name = "\(photoNameChange[0])"
        self.userImage.image = Manager.shared.userPhotoRead(jpg: name)
        self.userImage.layer.cornerRadius = self.userImage.bounds.height / 2
        
        self.userNameLB.text = data.userNickName
        
        let date = data.recordDate!
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = dateFormat.string(from: date)
        self.dateLB.text = dateString
        
        self.mainLB.text = data.recordText
        
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    
    @IBAction func recordPlayer(_ sender: Any) {
    }
    
}
