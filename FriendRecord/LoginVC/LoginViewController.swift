import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var loginEmailTF: UITextField!
    @IBOutlet weak var loginPassWordTF: UITextField!
    @IBOutlet weak var loginSV: UIScrollView!
    @IBOutlet weak var loginFBBT: FBLoginButton!
    
    var isloginOK: Int = 0
    var recodeArry :[String:Int]!
    var userLoginArry :[UserData] = []
    
    var t :UIButton!
    
//    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.loginFBBT.permissions = ["public_profile","email"]
//        self.loginFBBT.delegate = self
        
        Profile.enableUpdatesOnAccessTokenChange(true)//把通知打開 by fb
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProfile), name: Notification.Name.ProfileDidChange, object: nil)
        
//        self.loginEmailTF.delegate = self
//        self.loginPassWordTF.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.createGradientLayer()
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    //MARK: func - Login to app.
    @IBAction func loginGo(_ sender: Any) {
        //self.t.setTitle("T", for: .normal)
        self.checkTextfiel()
        self.checkEmail()
        self.checkPassword()
        
        guard self.isloginOK == 0 else {
            print("********** user login data have error. **********")
            self.isloginOK = 0
            Manager.shared.okAlter(vc: self, title: "請確認帳號密碼是否空白或是正確", message: "")
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
                            Manager.shared.okAlter(vc: self, title: "請確認信箱與密碼否有錯誤", message: "請重新輸入")
                            print("********** user is login fail. **********")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        //set isLogin key to UserDefaults.
                        let loginUserDefault = UserDefaults.standard
                        loginUserDefault.set(true , forKey: "isLogin")
                        
                        Manager.recordDataUser.removeAll()
                        
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
                    let emailHead = self.userLoginArry[0].email!.split(separator: "@")
                    userDataDefault.set("\(emailHead[0])" , forKey: "emailHead")
                    userDataDefault.string(forKey: "pswd")
                    userDataDefault.set("\(self.userLoginArry[0].pswd!)" , forKey: "pswd")
                    userDataDefault.string(forKey: "nickname")
                    userDataDefault.set("\(self.userLoginArry[0].nickname!)" , forKey: "nickname")
                    userDataDefault.string(forKey: "bf")
                    let bf = self.userLoginArry[0].bf!.replacingOccurrences(of: "", with: "/")
                    userDataDefault.set("\(bf)" , forKey: "bf")
                    userDataDefault.string(forKey: "gende")
                    userDataDefault.set("\(self.userLoginArry[0].gender!)" , forKey: "gender")
                    
                    Manager.shared.downLoadUserPhoto()
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
            Manager.shared.okAlter(vc: self, title: "請確認登入資訊是否有空白", message: "")
            self.isloginOK += 1
            return
        }
    }
    
    //MARK: func - check email.
    func checkEmail() {
        let emailRegex = "^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"
        let emailTest = NSPredicate(format: "SELF MATCHES%@", emailRegex)
        guard emailTest.evaluate(with: self.loginEmailTF.text) == true else {
            Manager.shared.okAlter(vc: self, title: "請確認登入email格式是否正確", message: "")
            self.isloginOK += 1
            return
        }
    }
    
    //MARK: func - chaek Password.
    func checkPassword() {
        let allRegex = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9]{8,12}+$")
        guard allRegex.evaluate(with: self.loginPassWordTF.text) == true else {
            Manager.shared.okAlter(vc: self, title: "請確認登入密碼格式是否正確", message: "")
            self.isloginOK += 1
            return
        }
    }
    
    //MARK: func - <#code#>
    func getFBSDKUserDetails(){
        guard let _ = AccessToken.current else{return}
        let param = ["fields":"email ,birthday ,gender"]
        let graphRequest = GraphRequest(graphPath: "me",parameters: param)
        graphRequest.start(completionHandler: { (connection, result, error) in
            if(error == nil) {
                //print("result \(result!)")
                let info = result as! Dictionary<String,AnyObject>
                if let email = info["email"] {
                    print("email  = \(email)")
                }
                if let birthday = info["birthday"] {
                    print("birthday = \(birthday)")
                }
                if let gender = info["gender"] {
                    print("gender = \(gender)")
                }
            } else {
                print("error \(error!)")
            }
        })
    }
    
    @objc func updateProfile() {
        
        if let profile = Profile.current { //current 使用者登入帳號
            print("\(profile.userID)")
            print("\(profile.name!)")
        }
        
    }
    
//    func createGradientLayer() {
//        self.gradientLayer = CAGradientLayer()
//
//        self.gradientLayer.frame = self.view.bounds
//
//        self.gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
//
//        self.mainView.layer.addSublayer(gradientLayer)
//    }
    
}

/*------------------------------------------------------------ Protocol. ------------------------------------------------------------*/
extension LoginViewController :LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        self.getFBSDKUserDetails()
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
}

extension LoginViewController: UITextFieldDelegate {
    
//    //MARK: Protocol - UITextFiel Delegate.
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        //return close keyboard.
//        textField.resignFirstResponder()
//        return true
//    }
//    //touch textfiel begin.
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.loginSV.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
//    }
//    //touch textfiel end.
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.loginSV.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//    }
}
