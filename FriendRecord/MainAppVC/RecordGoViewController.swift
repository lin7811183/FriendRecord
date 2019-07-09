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
    
    var recordIDArry :[String:Double]!
    
    var textViewData :[String] = ["微笑","火爆","憂愁","心碎","厭世","驚恐","靈異","感情","職場"]
    var textViewPicker = UIPickerView()
    
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
        
        //UIPickerView.
        self.textViewPicker.delegate = self
        self.textViewPicker.dataSource = self
        self.textView.inputView = self.textViewPicker
        
        let longGestre = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.starRecordBT.addGestureRecognizer(longGestre)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userEmail = UserDefaults.standard
        let emailHead = userEmail.string(forKey: "emailHead")
        self.userImage.image = Manager.shared.userPhotoRead(jpg: emailHead!)
        
        self.textView.text = "請選擇心情~"
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
            self.textView.text = "請選擇心情~"
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
                dateFormat.dateFormat = "yyyyMMddHHmmss"
                let dateString = dateFormat.string(from: now)
                
                let fileName = "\(dateString)_\(recordDataEmailHead!)"
                let filePathURL = Manager.shared.fileDocumentsPath(fileName: "\(fileName).caf")
                
                //save new record.
                newRecord.recordSendUser = recordDataEmail
                newRecord.recordFileName = "\(fileName).caf"
                newRecord.userNickName = userNickName!
                newRecord.recordText = self.textView.text
                newRecord.messageSum = 0.0
                
                let dateFormat2 :DateFormatter = DateFormatter()
                dateFormat2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString2 = dateFormat2.string(from: now)
                newRecord.recordDate = dateString2
                
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
            dateFormat.locale = Locale(identifier: "zh_Hant_TW") // 設定地區(台灣)
            dateFormat.timeZone = TimeZone(identifier: "Asia/Taipei") // 設定時區(台灣)
            dateFormat.dateFormat = "yyyyMMddHHmmss"
            let dateString = dateFormat.string(from: now)
            
            let fileName = "\(dateString)_\(recordDataEmailHead!)"
            let filePathURL = Manager.shared.fileDocumentsPath(fileName: "\(fileName).caf")
            
            //save new record.
            newRecord.recordSendUser = recordDataEmail
            newRecord.recordFileName = "\(fileName).caf"
            newRecord.userNickName = userNickName!
            newRecord.recordText = self.textView.text
            
            let dateFormat2 :DateFormatter = DateFormatter()
            dateFormat2.locale = Locale(identifier: "zh_Hant_TW") // 設定地區(台灣)
            dateFormat2.timeZone = TimeZone(identifier: "Asia/Taipei") // 設定時區(台灣)
            dateFormat2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString2 = dateFormat2.string(from: now)
            newRecord.recordDate = dateString2
            
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
            let text :String!
            if Manager.recordData[0].recordText! == "請選擇心情~" {
                text = "健忘選心情了!"
            } else {
                text = Manager.recordData[0].recordText!
            }
            let recordDataString = "心情:\(text!)\n時間:\(Manager.recordData[0].recordDate!)\n長度:\(Manager.recordData[0].recordTime!)"
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
        
        //call Mysql get record id.
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/RecordPen/Get_Record_Pen_ID.php") {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
                guard let jsData = data else {
                    return
                }
//                let recordID = String(data: data!, encoding: .utf8)
//                print(recordID!)
                let jsDocode = JSONDecoder()
                self.recordIDArry = try? jsDocode.decode([String:Double].self, from: jsData)
                //print("\(self.recordIDArry.first?.value)")
                guard let id = self.recordIDArry.first?.value else {
                    print("********** get record id error. **********")
                    return
                }
                
                DispatchQueue.main.async {
                    Manager.recordData[0].recordID = id
                    //push to server.
                    if let url = URL(string: "http://34.80.138.241:81/FriendRecord/RecordPen/Upload_Record_Pen.php") {
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        
                        let data = Manager.recordData[0]
                        let param = ("recordID=\(Int(data.recordID!))&recordDate=\(data.recordDate!)&recordSendUser=\(data.recordSendUser!)&userNickName=\(data.userNickName!)&recordFileName=\(data.recordFileName!)&recordText=\(data.recordText!)&recordTime=\(data.recordTime!)")
                        print("\(param)")
                        request.httpBody = param.data(using: .utf8)
                        
                        let session = URLSession.shared
                        let task = session.dataTask(with: request) { (data, response, error) in
                            if let e = error {
                                print("erroe \(e)")
                            }else {
                                let reCode = String(data: data!, encoding: .utf8)
                                print(reCode)
                            }
                        }
                        task.resume()
                    }
                    //Upload Record File.
                    if let url = URL(string: "http://34.80.138.241:81/FriendRecord/RecordPen/Upload_Record_File.php?recordFileName=\(Manager.recordData[0].recordFileName!)") {
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        
                        //Upload Record file.
                        let filePath =  NSHomeDirectory()+"/Documents/"+Manager.recordData[0].recordFileName!
                        let recordData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
                        
                        let session = URLSession.shared
                        let uploadTask = session.uploadTask(with: request, from: recordData) {
                            (data:Data?, response:URLResponse?, error:Error?) -> Void in
                            if let e = error {
                                print("erroe \(e)")
                            }else {
                                let reCode = String(data: data!, encoding: .utf8)
                                print(reCode)
                            }
                        }
                        uploadTask.resume()
                    }
                    self.delegate.sendRecordPen(Record: Manager.recordData[0])
                    self.dismiss(animated: true, completion: nil)
                }
            }
            task.resume()
        }
    }
}

/*------------------------------------------------------------ Protocl. ------------------------------------------------------------*/
extension RecordGoViewController :UITextViewDelegate {
    //MARK: Protocol - textFiel Delegate.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView.text = ""
        self.textView.textColor = UIColor.black
        return true
    }
}

extension RecordGoViewController :UIPickerViewDataSource {
    //MARK: Protocol - UIPickerView DataSiurce
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.textViewData.count
    }
}

extension RecordGoViewController :UIPickerViewDelegate {
    //MARK: Protocol UIPicker Delegate
    //gate data arry data
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.textViewData[row]
    }
    //Show textFiel text
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textView.text = self.textViewData[row]
        self.view.endEditing(false)
    }
}

