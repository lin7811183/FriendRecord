import UIKit

class RippleAnimationViewController: UIViewController {
    
    @IBOutlet weak var test: UIButton!
    
    var istest = false
    let rippleLayer = RippleLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rippleLayer.position = CGPoint(x:test.center.x, y: test.center.y)
        self.view.layer.addSublayer(rippleLayer)
        
        self.test.layer.cornerRadius = 0.5 * self.test.bounds.size.width
    }

    
    @IBAction func test(_ sender: Any) {
        
        if istest == true {
            print("true")
            self.rippleLayer.startAnimation()
            self.istest = false
        } else {
            print("false")
            self.rippleLayer.stopAnimation()
            self.istest = true
        }
        
    }
    
}
