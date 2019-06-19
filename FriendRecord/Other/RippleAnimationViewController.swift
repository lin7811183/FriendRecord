import UIKit

class RippleAnimationViewController: UIViewController {
    
    
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rippleLayer = RippleLayer()
        rippleLayer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY);
        
        self.view.layer.addSublayer(rippleLayer)
        rippleLayer.startAnimation()
        
    }

    
    
}
