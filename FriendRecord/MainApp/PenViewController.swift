import UIKit
import AVKit

class PenViewController: UIViewController {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var mainLB: UILabel!
    @IBOutlet weak var penableView: UITableView!
    
    var selectIndexPath :Int!
    
    var player = AVPlayer()
    var playerViewController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectIndexPath = Manager.indexPath
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

        self.dateLB.text = data.recordDate!
        
        self.mainLB.text = data.recordText
        
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    @IBAction func recordPlayer(_ sender: Any) {
        
        self.selectIndexPath = Manager.indexPath
        //Show Data to UI.
        guard let index = self.selectIndexPath else {
            print("********** get error index. **********")
            return
        }
//        let recordFileName = Manager.recordData[index].recordFileName!
//        let filePath = Manager.shared.fileDocumentsPath(fileName: recordFileName)
        let fileURL = NSHomeDirectory()+"/Documents/"+Manager.recordData[index].recordFileName!
        let videoURL = URL(fileURLWithPath: fileURL)
        //Play Record.
        player = AVPlayer(url: videoURL)
        player.volume = 1
        playerViewController.player = player
        player.volume = 1
        //self.present(playerViewController ,animated: true ,completion: nil)
    }
    
}
