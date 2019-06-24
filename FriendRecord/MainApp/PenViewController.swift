import UIKit
import AVKit

class PenViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var mainLB: UILabel!
    @IBOutlet weak var penableView: UITableView!
    @IBOutlet weak var playerBT: UIButton!
    
    var selectIndexPath :Int!
    
    var isPlayer = true
    let rippleLayer = RippleLayer()
    
    var muisePlayer :AVAudioPlayer?
    
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
        
        self.rippleLayer.position = CGPoint(x:self.playerBT.center.x, y: self.playerBT.center.y)
        self.view.layer.addSublayer(rippleLayer)
        
        self.playerBT.layer.cornerRadius = 0.5 * self.playerBT.bounds.size.width
        
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    @IBAction func recordPlayer(_ sender: Any) {
        
        guard self.isPlayer == true else {
            self.playerBT.setImage(UIImage(named: "Stop.png"), for: .normal)
            self.muisePlayer?.stop()
            print("********** Stop player Record. **********")
            self.rippleLayer.stopAnimation()
            self.isPlayer = true
            return
        }
        
        self.selectIndexPath = Manager.indexPath
        //Show Data to UI.
        guard let index = self.selectIndexPath else {
            print("********** get error index. **********")
            return
        }
        
        self.playerBT.setImage(UIImage(named: "Star.png"), for: .normal)
        
        let filePathURL = Manager.shared.fileDocumentsPath(fileName: Manager.recordData[index].recordFileName!)
        //Play Record.
        self.muisePlayer = try? AVAudioPlayer(contentsOf: filePathURL)
        self.muisePlayer?.numberOfLoops = -1
        self.muisePlayer?.prepareToPlay()
        
        //Create Audio Session.
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.playback)
        
        //Record Player.
        muisePlayer?.play()
        
        print("********** Star player Record. **********")
        self.rippleLayer.startAnimation()
        self.isPlayer = false
    }
    
}
