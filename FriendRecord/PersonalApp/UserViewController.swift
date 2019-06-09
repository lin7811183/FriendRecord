import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userNickNameLB: UILabel!
    @IBOutlet weak var UsergenderLB: UILabel!
    @IBOutlet weak var userBfLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userData = UserDefaults.standard
        
        let uesrDataNickName = userData.string(forKey: "nickname")
        self.userNickNameLB.text = uesrDataNickName
        
        let userDataGender = userData.string(forKey: "gender")
        self.UsergenderLB.text = userDataGender
        
        let userDataBf = userData.string(forKey: "bf")
        self.userBfLB.text = userDataBf
    }
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/
    //MARK: func - logout button
    @IBAction func logout(_ sender: Any) {
        //set isLogin key to UserDefaults.
        let loginUserDefault = UserDefaults.standard
        loginUserDefault.set(false , forKey: "isLogin")
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
        print("********** user is logout secure. **********")
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
