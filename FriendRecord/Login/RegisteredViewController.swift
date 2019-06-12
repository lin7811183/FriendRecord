import UIKit

class RegisteredViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var bfTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var registeredBT: UIButton!
    @IBOutlet weak var registeredSV: UIScrollView!
    
    var genderData :[String] = ["男孩","女孩","彩虹","不說"]
    var genderpicker = UIPickerView()
    
    var bfDatePicker = UIDatePicker()
    
    var isRegistered :Int = 0
    var recodeArry :[String:Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting UIButton Color.
//        registeredBT.layer.borderColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
//        registeredBT.layer.borderWidth = 1
        
        //UITextFiel Delegate.
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        self.userTF.delegate = self
        
        //dismissKeyboard.
        self.hideKeyboardWhenTappedAround()
        
        //UIPickerView.
        self.genderpicker.delegate = self
        self.genderpicker.dataSource = self
        self.genderTF.inputView = self.genderpicker
        
        //UIDatePicker.
        self.bfDatePicker.datePickerMode = .date
        self.bfDatePicker.locale = Locale(identifier: "zh_TW")
        self.bfTF.keyboardAppearance = .dark
        self.bfTF.inputView = self.bfDatePicker
        bfDatePicker.addTarget(self, action: #selector(changDate(datePicker:)), for: .valueChanged)
        
    }
    
    /*------------------------------------------------------------ Function ------------------------------------------------------------*/
    //MARK: func - datapicker formatter.
    @objc func changDate(datePicker :UIDatePicker) {
        let date = self.datapickerformat(datePicker: datePicker)
        bfTF.text = date
    }
    
    //MARK: func - registered.
    @IBAction func registered(_ sender: Any) {
        //check registered data.
        self.checkTextfiel()
        self.checkEmail()
        self.checkPassword()
        self.checkUser()
        
        guard self.isRegistered == 0 else {
            print("********** user registered data have error. **********")
            self.isRegistered = 0
            return
        }
        //Create accountID.
        let accountID = UUID().uuidString
                
        //URL Sesion.
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Registered/Registered.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            guard let email = self.emailTF.text,let password = self.self.passwordTF.text,let userName = self.userTF.text,let bf = self.bfTF.text,let gender = self.genderTF.text else {
                return
            }
            
            let param = "accountID=\(accountID)&email=\(email)&password=\(password)&userName=\(userName)&birthday=\(bf)&gender=\(gender)"
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print("erroe \(e)")
                }else {
                    //let reCode = String(data: data!, encoding: .utf8)
                    //print(reCode!)
                    //gat php reture data to json.
                    let jsDocode = JSONDecoder()
                    do {
                        self.recodeArry = try jsDocode.decode([String:Int].self, from: data!)
                        guard self.recodeArry.first!.value == 1 else {
                            DispatchQueue.main.async {
                                print("********** user registered fail. **********")
                                
                                self.okAlter(title: "信箱有人使用過摟", message: "再想想新的信箱")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            print("********** user registered secure. **********")
                            
                            let alter = UIAlertController(title: "註冊完成", message: "歡迎使用錄音交友APP",preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
                                //set isLogin key to UserDefaults.
                                let loginUserDefault = UserDefaults.standard
                                loginUserDefault.set(true , forKey: "isLogin")
                                //present to tabbarVC.
                                let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! MyTabBarController
                                self.present(tabbarVC, animated: true, completion: nil)
                                
                                //set user data key to UserDefaults.
                                let userDataDefault = UserDefaults.standard
                                userDataDefault.string(forKey: "email")
                                userDataDefault.set("\(email)" , forKey: "email")
                                userDataDefault.string(forKey: "pswd")
                                userDataDefault.set("\(password)" , forKey: "pswd")
                                userDataDefault.string(forKey: "nickname")
                                userDataDefault.set("\(userName)" , forKey: "nickname")
                                userDataDefault.string(forKey: "bf")
                                userDataDefault.set("\(bf)" , forKey: "bf")
                                userDataDefault.string(forKey: "gende")
                                userDataDefault.set("\(gender)" , forKey: "gender")
                                let emailHead = email.split(separator: "@")
                                userDataDefault.set("\(emailHead[0])" , forKey: "emailHead")
                                userDataDefault.string(forKey: "pswd")
                                print("********** user is data rember secure. **********")
                            }
                            alter.addAction(okAction)
                            self.present(alter, animated: true, completion: nil)
                        }
                    }catch {
                        print("jsdocoder reeor : \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK: func - check all textfiels are =  "".
    func checkTextfiel() {
        guard self.emailTF.text != "", self.passwordTF.text! != "", self.userTF.text! != "", self.bfTF.text! != "", self.genderTF.text! != ""  else {
            self.okAlter(title: "請確認註冊資訊是否皆有填寫完成", message: "")
            self.isRegistered += 1
            return
        }
    }
    
    //MARK: func - check email.
    func checkEmail() {/*林易興*/
        let emailRegex = "^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"
        let emailTest = NSPredicate(format: "SELF MATCHES%@", emailRegex)
        guard emailTest.evaluate(with: self.emailTF.text) == true else {
            self.okAlter(title: "請確認這註冊email是否有正確", message: "")
            self.isRegistered += 1
            return
        }
    }
    
    //MARK: func - chaek Password.
    func checkPassword() {
        let allRegex = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9]{8,12}+$")
        guard allRegex.evaluate(with: self.passwordTF.text) == true else {
            self.okAlter(title: "請確認註冊密碼是否有符合要求", message: "")
            self.isRegistered += 1
            return
        }
    }
    
    //MARK: func - chek Uesr Name.
    func checkUser() {
        let username = "^[\\u4E00-\\u9FA5]{2,4}$"
        let userRegex = NSPredicate(format: "SELF MATCHES %@", username)
        guard userRegex.evaluate(with: self.userTF.text) == true else {
            self.okAlter(title: "請輸入正確的中文名字與字數", message: "")
            self.isRegistered += 1
            return
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


extension RegisteredViewController :UITextFieldDelegate {
    //MARK: Protocol - UITextFiel Delegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //return close keyboard.
        textField.resignFirstResponder()
        return true
    }
    //touch textfiel begin.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.registeredSV.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
    }
    //touch textfiel end.
    func textFieldDidEndEditing(_ textField: UITextField) {
         self.registeredSV.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension RegisteredViewController :UIPickerViewDataSource {
    //MARK: Protocol - UIPickerView DataSiurce
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderData.count
    }
}

extension RegisteredViewController :UIPickerViewDelegate {
    //MARK: Protocol UIPicker Delegate
    //gate data arry data
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderData[row]
    }
    //Show textFiel text
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTF.text = self.genderData[row]
        self.view.endEditing(false)
    }
}
