import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmailTF: UITextField!
    @IBOutlet weak var loginPassWordTF: UITextField!
    @IBOutlet weak var loginSV: UIScrollView!
    
    var isloginOK: Int = 0
    var recodeArry :[String:Int]!
    var userLoginArry :[UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dismissKeyboard.
        self.hideKeyboardWhenTappedAround()
        
        self.loginEmailTF.delegate = self
        self.loginPassWordTF.delegate = self
        
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    //MARK: func - Login to app.
    @IBAction func loginGo(_ sender: Any) {
        self.checkTextfiel()
        self.checkEmail()
        self.checkPassword()
        
        guard self.isloginOK == 0 else {
            print("********** user login data have error. **********")
            self.isloginOK = 0
            return
        }
        
        //Post PHP(check user login data).
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Login/Login.php") {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "email=\(self.loginEmailTF.text!)&password=\(self.loginPassWordTF.text!)"
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, respones, error) in
                if let e = error {
                    print("uesr login check data URL Session error: \(e)")
                    return
                }
                guard let jsData = data else {
                    return
                }
                //let reCode = String(data: data!, encoding: .utf8)
                //print(reCode!)
                let jsDocode = JSONDecoder()
                do {
                    self.recodeArry = try jsDocode.decode([String:Int].self, from: jsData)
                    guard self.recodeArry.first!.value == 1 else {
                        DispatchQueue.main.async {
                            self.okAlter(title: "請確認信箱與密碼否有錯誤", message: "請重新輸入")
                            print("********** user is login fail. **********")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        //set isLogin key to UserDefaults.
                        let loginUserDefault = UserDefaults.standard
                        loginUserDefault.set(true , forKey: "isLogin")
                        //present to tabberVC.
                        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! MyTabBarController
                        self.present(tabbarVC, animated: true, completion: nil)
                        print("********** user is login secure. **********")
                    }
                }catch {
                    print("uesr login check jsdocoder reeor : \(error)")
                }
            }
            task.resume()
        }
        //Post PHP(get user login data).
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/Login/Login_User.php") {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let param = "email=\(self.loginEmailTF.text!)"
            request.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, respones, error) in
                if let e = error {
                    print("uesr login load data URL Session error \(e)")
                    return
                }
                guard let jsData = data else {
                    return
                }
//                let reCode = String(data: jsData, encoding: .utf8)
//                print(reCode!)
                
                let decoder = JSONDecoder()
                do {
                    self.userLoginArry = try decoder.decode([UserData].self, from: jsData)
                    
                    //set user data key to UserDefaults.
                    let userDataDefault = UserDefaults.standard
                    userDataDefault.string(forKey: "email")
                    userDataDefault.set("\(self.userLoginArry[0].email!)" , forKey: "email")
                    userDataDefault.string(forKey: "pswd")
                    userDataDefault.set("\(self.userLoginArry[0].pswd!)" , forKey: "pswd")
                    userDataDefault.string(forKey: "nickname")
                    userDataDefault.set("\(self.userLoginArry[0].nickname!)" , forKey: "nickname")
                    userDataDefault.string(forKey: "bf")
                    let bf = self.userLoginArry[0].bf!.replacingOccurrences(of: "", with: "/")
                    userDataDefault.set("\(bf)" , forKey: "bf")
                    userDataDefault.string(forKey: "gende")
                    userDataDefault.set("\(self.userLoginArry[0].gender!)" , forKey: "gender")
                    print("********** user is data rember secure. **********")
                }catch {
                    print("uesr login load jsdocoder reeor : \(error)")
                }
            }
            task.resume()
        }
    }
    
    //MARK: func - check all textfiels are =  "".
    func checkTextfiel() {
        guard self.loginEmailTF.text != "", self.loginPassWordTF.text! != "" else {
            self.okAlter(title: "請確認登入資訊是否有空白", message: "")
            self.isloginOK += 1
            return
        }
    }
    
    //MARK: func - check email.
    func checkEmail() {
        let emailRegex = "^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"
        let emailTest = NSPredicate(format: "SELF MATCHES%@", emailRegex)
        guard emailTest.evaluate(with: self.loginEmailTF.text) == true else {
            self.okAlter(title: "請確認登入email格式是否正確", message: "")
            self.isloginOK += 1
            return
        }
    }
    
    //MARK: func - chaek Password.
    func checkPassword() {
        let allRegex = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9]{8,12}+$")
        guard allRegex.evaluate(with: self.loginPassWordTF.text) == true else {
            self.okAlter(title: "請確認登入密碼格式是否正確", message: "")
            self.isloginOK += 1
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

extension LoginViewController: UITextFieldDelegate {
    //MARK: Protocol - UITextFiel Delegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //return close keyboard.
        textField.resignFirstResponder()
        return true
    }
    //touch textfiel begin.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.loginSV.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    //touch textfiel end.
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.loginSV.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
