import UIKit
import AVFoundation
import AVKit

protocol RecordGoViewControllerDelegate {
    func sendRecordPen()
}

class RecordGoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timerLB: UILabel!
    @IBOutlet weak var starRecordBT: UIButton!
    @IBOutlet weak var sendRecordPen: UIBarButtonItem!
    
    var delegate :RecordGoViewControllerDelegate!
    
    //建立AudioRecorder元件
    var voiceRecorder: AVAudioRecorder?
    
//    var recordData :[Record] = []
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
        
        self.sendRecordPen.isEnabled = false
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
            
            self.sendRecordPen.isEnabled = true
            
            //Star timer.
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            //準備錄音檔案格式相關內容設定資訊
            let setting: [String: Any] = [ AVFormatIDKey: kAudioFormatAppleIMA4 ,//錄音檔案格
                                        AVSampleRateKey: 22050.0 ,//Sample Rate
                                        AVNumberOfChannelsKey: 1 ,//Channel數量
                                        AVLinearPCMBitDepthKey: 16 ,//資料Bits數
                                        AVLinearPCMIsFloatKey: false ,//其他PCM相關資料
                                        AVLinearPCMIsBigEndianKey: false ]
            let newRecord = Record()
            
            //record file path URL.
            let recordData = UserDefaults.standard
            let recordDataEmailHead = recordData.string(forKey: "emailHead")
            let recordDataEmail = recordData.string(forKey: "email")
            
            let now :Date = Date()
            let dateFormat :DateFormatter = DateFormatter()
            dateFormat.dateFormat = "yyyyMMddHHmm"
            let dateString = dateFormat.string(from: now)
            
            let fileName = "\(dateString)_\(recordDataEmailHead!)"
            let filePathURL = Manager.shared.fileDocumentsPath(fileName: "\(fileName).caf")
            
            //save new record.
            newRecord.recordSendUser = recordDataEmail
            newRecord.recordFileName = "\(fileName).caf"
            newRecord.recordText = self.textView.text
            newRecord.recordDate = now
            
            //self.recordData.append(newRecord)
            Manager.recordData.append(newRecord)
            //Manager.recordData.insert(newRecord, at: 0)
            
            //將路徑以及設定的Dictionary資料用於產生AVAudioRecorder
            self.voiceRecorder = try? AVAudioRecorder(url: filePathURL, settings: setting)
            //準備錄音
            self.voiceRecorder?.prepareToRecord()
            //設定Audio Session Category
            try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            
            print("********** Star Record. **********")
            self.voiceRecorder?.record()
        }
        else if sender.state == .ended {
            print("********** Stop Record. **********")
            self.voiceRecorder?.stop()
            
            //self.recordData.first?.recordTime = self.timerLB.text
            Manager.recordData[Manager.recordData.count - 1].recordTime = self.timerLB.text
            //Manager.recordData.first?.recordTime = self.timerLB.text
            
            //cleat timer.
            self.timer.invalidate()
            self.timerLB.text = ""
            count = 0.0
        }
    }
    //MARK: func - cancel RecordGo.
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: func - Send Record Pen.
    @IBAction func SendRecordPen(_ sender: Any) {
        self.delegate.sendRecordPen()
        self.dismiss(animated: true, completion: nil)
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
