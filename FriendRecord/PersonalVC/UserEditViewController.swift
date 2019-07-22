import UIKit

protocol UserEditViewControllerDelegate {
    func updateFinishUserData()
}

class UserEditViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNickTF: UITextField!
    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var userBfTF: UITextField!
    @IBOutlet weak var userGenderFT: UITextField!
    @IBOutlet weak var done: UIBarButtonItem!
    
    var genderData :[String] = ["男孩","女孩","彩虹","不說"]
    var genderpicker = UIPickerView()
    
    var bfDatePicker = UIDatePicker()
    
    var delegate :UserEditViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = UserDefaults.standard

        let uesrDataNickName = userData.string(forKey: "nickname")
        self.userNickTF.text = uesrDataNickName!
        
        let userDataEmail = userData.string(forKey: "email")
        self.userEmailTF.text = userDataEmail!
        
        self.userImage.image = Manager.shared.userPhotoRead(jpg: Manager.shared.emailChangeHead(email: userDataEmail!))
        self.userImage.layer.cornerRadius = self.userImage.bounds.height / 2
        
        let userDataBf = userData.string(forKey: "bf")
        if userDataBf! == "" {
            self.userBfTF.text = "未填寫"
        } else {
            self.userBfTF.text = userDataBf!
        }
        
        let userDataGender = userData.string(forKey: "gender")
        if userDataGender == "" {
            self.userGenderFT.text = "未填寫"
        } else {
             self.userGenderFT.text = userDataGender!
        }
        
        self.userBfTF.addTarget(self, action: #selector(self.textfieldAction(textField:)), for: .touchDown)
        self.userGenderFT.addTarget(self, action: #selector(self.textfieldAction(textField:)), for: .touchDown)
        
        //UIPickerView.
        self.genderpicker.delegate = self
        self.genderpicker.dataSource = self
        self.userGenderFT.inputView = self.genderpicker
        
        //UIDatePicker.
        self.bfDatePicker.datePickerMode = .date
        self.bfDatePicker.locale = Locale(identifier: "zh_TW")
        self.userBfTF.keyboardAppearance = .dark
        self.userBfTF.inputView = self.bfDatePicker
        bfDatePicker.addTarget(self, action: #selector(changDate(datePicker:)), for: .valueChanged)
    }
    
    /*------------------------------------------------------------ Functions ------------------------------------------------------------*/
    @objc func textfieldAction(textField: UITextField) {
        self.done.isEnabled = true
    }
    //MARK: func - datapicker formatter.
    @objc func changDate(datePicker :UIDatePicker) {
        let date = Manager.shared.datapickerformat(datePicker: datePicker)
        self.userBfTF.text = date
    }
    //MARK: func - user cancel UserEditVC.
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: func - user update data.
    @IBAction func done(_ sender: Any) {
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Account/Accoount_Upload_UserPhoto/Update_User_Data.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            var bf :String = ""
            var gender :String = ""
            
            
            let userDataDefault = UserDefaults.standard
            
            userDataDefault.removeObject(forKey: "bf")
            userDataDefault.removeObject(forKey: "gender")

            userDataDefault.string(forKey: "bf")
            if self.userBfTF.text! == "未填寫" {
                bf = ""
                userDataDefault.set("" ,forKey: "bf")
            } else {
                bf = self.userBfTF.text!
                userDataDefault.set("\(self.userBfTF.text!)" ,forKey: "bf")
            }
            
            userDataDefault.string(forKey: "gende")
            if self.userGenderFT.text! == "未填寫" {
                gender = ""
                userDataDefault.set("" ,forKey: "gender")
            } else {
                gender = self.userGenderFT.text!
                userDataDefault.set("\(self.userGenderFT.text!)" ,forKey: "gender")
            }
            
            let param = "email=\(self.userEmailTF.text!)&bf=\(bf)&gender=\(gender)"
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }
                let reCode = String(data: data!, encoding: .utf8)
                print(reCode!)
            }
            task.resume()
        }
        DispatchQueue.main.async {
            self.delegate.updateFinishUserData()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UserEditViewController :UIPickerViewDataSource {
    //MARK: Protocol - UIPickerView DataSiurce
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderData.count
    }
}

extension UserEditViewController :UIPickerViewDelegate {
    //MARK: Protocol UIPicker Delegate
    //gate data arry data
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderData[row]
    }
    //Show textFiel text
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userGenderFT.text = self.genderData[row]
        self.view.endEditing(false)
    }
}
