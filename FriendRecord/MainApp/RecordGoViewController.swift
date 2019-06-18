import UIKit
import AVFoundation
import AVKit

protocol RecordGoViewControllerDelegate {
    func sendRecordPen(Record :Record)
}

class RecordGoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timerLB: UILabel!
    @IBOutlet weak var starRecordBT: UIButton!
    @IBOutlet weak var sendRecordPen: UIBarButtonItem!
    @IBOutlet weak var recordDataLB: UILabel!
    
    var delegate :RecordGoViewControllerDelegate!
    
    //建立AudioRecorder元件
    var voiceRecorder: AVAudioRecorder?
    
    var count = 0.0
    var timer = Timer()
    var toolRecordPan = Manager.recordData.count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //取得User錄音的同意
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (go) in
            print("********** User's consent to use the microphone. **********")
        }
        
        Manager.shared.hideKeyboardWhenTappedAround()
        
        self.textView.delegate = self
        
        let longGestre = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.starRecordBT.addGestureRecognizer(longGestre)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userEmail = UserDefaults.standard
        let emailHead = userEmail.string(forKey: "emailHead")
        self.userImage.image = Manager.shared.userPhotoRead(jpg: emailHead!)
        
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
        // sender.state = began
        if sender.state == .began {
            
            //if again record need clear old record data.
            guard toolRecordPan < Manager.recordData.count else {
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
                let userNickName = recordData.string(forKey: "nickname")
                
                let now :Date = Date()
                let dateFormat :DateFormatter = DateFormatter()
                dateFormat.dateFormat = "yyyyMMddHHmm"
                let dateString = dateFormat.string(from: now)
                
                let fileName = "\(dateString)_\(recordDataEmailHead!)"
                let filePathURL = Manager.shared.fileDocumentsPath(fileName: "\(fileName).caf")
                
                //save new record.
                newRecord.recordSendUser = recordDataEmail
                newRecord.recordFileName = "\(fileName).caf"
                newRecord.userNickName = userNickName!
                newRecord.recordText = self.textView.text
                newRecord.recordDate = now
                
                //self.recordData.append(newRecord)
                Manager.recordData.insert(newRecord, at: 0)
                //Manager.recordData.append(newRecord)
                //Manager.recordData.insert(newRecord, at: 0)
                
                //將路徑以及設定的Dictionary資料用於產生AVAudioRecorder
                self.voiceRecorder = try? AVAudioRecorder(url: filePathURL, settings: setting)
                //準備錄音
                self.voiceRecorder?.prepareToRecord()
                //設定Audio Session Category
                try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
                
                print("********** Star Record. **********")
                self.voiceRecorder?.record()
                
                self.sendRecordPen.isEnabled = true
                return
            }
            
            Manager.recordData.remove(at: 0)
            //self.starRecordBT.titleLabel?.text = "再次錄音"
            self.starRecordBT.setTitle("再次錄音", for: .normal)
//            self.textView.text = ""
            
            
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
            let userNickName = recordData.string(forKey: "nickname")
            
            let now :Date = Date()
            let dateFormat :DateFormatter = DateFormatter()
            dateFormat.dateFormat = "yyyyMMddHHmm"
            let dateString = dateFormat.string(from: now)
            
            let fileName = "\(dateString)_\(recordDataEmailHead!)"
            let filePathURL = Manager.shared.fileDocumentsPath(fileName: "\(fileName).caf")
            
            //save new record.
            newRecord.recordSendUser = recordDataEmail
            newRecord.recordFileName = "\(fileName).caf"
            newRecord.userNickName = userNickName!
            newRecord.recordText = self.textView.text
            newRecord.recordDate = now
            
            //self.recordData.append(newRecord)
            Manager.recordData.insert(newRecord, at: 0)
            //Manager.recordData.append(newRecord)
            //Manager.recordData.insert(newRecord, at: 0)
            
            //將路徑以及設定的Dictionary資料用於產生AVAudioRecorder
            self.voiceRecorder = try? AVAudioRecorder(url: filePathURL, settings: setting)
            //準備錄音
            self.voiceRecorder?.prepareToRecord()
            //設定Audio Session Category
            try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            
            print("********** Star Record. **********")
            self.voiceRecorder?.record()
            
            self.sendRecordPen.isEnabled = true
        }
        // sender.state == .ended
        else if sender.state == .ended {
            print("********** Stop Record. **********")
            self.voiceRecorder?.stop()
            
            Manager.recordData[0].recordTime = self.timerLB.text
           
            //cleat timer.
            self.timer.invalidate()
            self.timerLB.text = ""
            count = 0.0
            
            let row = 0
            let recordDataString = "主旨:\(Manager.recordData[0].recordText!)\n時間:\(Manager.recordData[0].recordDate!)\n長度:\(Manager.recordData[0].recordTime!)"
            self.textView.textColor = UIColor.black
            self.textView.text = recordDataString
            
            print("Manager.recordData:\(Manager.recordData.count)")
        }
    }
    //MARK: func - cancel RecordGo.
    @IBAction func cancel(_ sender: Any) {
        //if again record need clear old record data.
        guard toolRecordPan < Manager.recordData.count else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        Manager.recordData.remove(at: 0)
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: func - Send Record Pen.
    @IBAction func SendRecordPen(_ sender: Any) {
        self.delegate.sendRecordPen(Record: Manager.recordData[0])
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

