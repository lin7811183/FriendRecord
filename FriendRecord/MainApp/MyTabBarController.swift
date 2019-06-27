import UIKit

class MyTabBarController: UITabBarController {
    
    @IBOutlet weak var tabbarItem: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //check is login and registered.
        let loginUserDefault = UserDefaults.standard
        
        //read userdefault is login or registered?
        let checkLogin = loginUserDefault.bool(forKey: "isLogin")
        print("********** user login \(checkLogin) **********")
        
        guard checkLogin == true else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            return
        }
    }
    
    
    
    /*------------------------------------------------------------ function ------------------------------------------------------------*/


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
