import UIKit

class GoAppViewController: UIViewController {

    @IBOutlet weak var go: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.go.layer.cornerRadius = 5.0
        self.go.layer.borderWidth = 1
        self.go.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func goApp(_ sender: Any) {
        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! MyTabBarController
        self.present(tabbarVC, animated: true, completion: nil)
    }
}
