import UIKit

class FriendMenuViewController: UIViewController {
    
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet var mainView: UIView!
    
    var friendData = ["林易興"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.friendTableView.dataSource = self
        self.friendTableView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*------------------------------------------------------------ Functions. ------------------------------------------------------------*/
    //MARK: func - disMiss FriendVC.
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FriendMenuViewController :UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendTableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.textLabel?.text = self.friendData[indexPath.row]
        
        return cell
    }
    
    
}
