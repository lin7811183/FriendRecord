import UIKit

class RecordGoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timerLB: UILabel!
    @IBOutlet weak var starRecordBT: UIButton!
    
    var count = 0.0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Manager.shared.hideKeyboardWhenTappedAround()
        
        self.textView.delegate = self
        
        let longGestre = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.starRecordBT.addGestureRecognizer(longGestre)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userImage.image = Manager.shared.userPhotoRead()
        
        self.textView.text = "請給錄音帶一個主題吧~"
        self.textView.textColor = UIColor.gray
        self.textView.layer.borderColor = UIColor.black.cgColor
        self.textView.layer.borderWidth = 1.0
        self.textView.layer.cornerRadius = 5.0
        
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    //MARK: func - touch outhr close keyborad.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        guard self.textView.text != "" else{
            self.textView.text = "請給錄音帶一個主題吧~"
            self.textView.textColor = UIColor.gray
            return
        }
        
    }
    //MARK: func - cancel RecordGo.
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: func - Updata time.
    @objc func updateTimer() {
        self.count = count + 0.1
        var ss = self.count.truncatingRemainder(dividingBy: 60.0)
        if ss < 10 {
            self.timerLB.text = "\((Int(self.count) / 60)):0\(String(format: "%.1f",ss))"
        }else {
            self.timerLB.text = "\((Int(self.count) / 60)):\(String(format: "%.1f",ss))"
        }
    }
    //MARK: func - star record BT long press.
    @objc func longPress(sender : UIGestureRecognizer) {
        if sender.state == .began {
            print("********** Star Record. **********")
            
            //Star timer.
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            //write the function for start recording the voice here
        }
        else if sender.state == .ended {
            print("********** Stop Record. **********")
            
            //cleat timer.
            self.timer.invalidate()
            self.timerLB.text = ""
            count = 0.0
        }
    }
}


extension RecordGoViewController :UITextViewDelegate {
    //MARK: Protocol - textFiel Delegate.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView.text = ""
        self.textView.textColor = UIColor.black
        return true
    }
}
