import UIKit

class MainAppViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let userCellValue = Record()
        userCellValue.userCellLB = "發個錄音帶給大家聽聽~"
        Manager.recordData.append(userCellValue)
        //self.tableViewData.append(userCellValue)
        //let userCellValue2 = Record()
        //userCellValue2.userCellLB = "Test"
        //self.tableViewData.append(userCellValue2)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPoRecordBT: UIButton!
    
    //var tableViewData :[Record] = Manager.recordData
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //check User Photo is new or downLoad to server.
        let userPhoto = UserDefaults.standard
        let isUserPhoto = userPhoto.bool(forKey: "isUserPhoto")
        guard isUserPhoto == false else {
            let indexpath = IndexPath(row: 0, section: 0)
            self.tableView.reloadRows(at: [indexpath], with: .automatic)
            //new user Photo.
            let userDataDefault = UserDefaults.standard
            userDataDefault.bool(forKey: "isUserPhoto")
            userDataDefault.set(false , forKey: "isUserPhoto")
            return
        }
    }
    
    @IBAction func test(_ sender: Any) {
        print("\(Manager.recordData.count)")
        
        let new = Record()
        new.recordText = "New"
        
        Manager.recordData.append(new)
        
        let inserIndexPath = IndexPath(row: Manager.recordData.count - 1, section: 0)
        self.tableView.insertRows(at: [inserIndexPath], with: .automatic)
        
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

extension MainAppViewController :UITableViewDataSource ,UITableViewDelegate{
    //MARK:UITableDataSource protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.tableViewData.count
        return Manager.recordData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! MyUserTableViewCell
            cell.imageUserPhoto.layer.cornerRadius = cell.imageUserPhoto.bounds.height / 2
            cell.imageUserPhoto.image = Manager.shared.userPhotoRead()
            //Auto change cell hight.
            self.tableView.rowHeight = cell.showLB.bounds.height + 50
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! MyRecordTableViewCell
            //cell.testLB.text = self.tableViewData[indexPath.row].recordFileName
            cell.testLB.text = Manager.recordData[indexPath.row].recordText
            //Auto change cell hight.
            self.tableView.rowHeight = cell.testLB.bounds.height + 20
            return cell
        }
        
    }
    
    //MARK: Protocol - tableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let recordgovc = self.storyboard?.instantiateViewController(withIdentifier: "recordgoVC") as! RecordGoViewController
            recordgovc.delegate = self
            self.present(recordgovc, animated: true, completion: nil)
        }
    }
}

extension MainAppViewController :RecordGoViewControllerDelegate {
    func sendRecordPen() {
        let inserIndexPath = IndexPath(row: Manager.recordData.count - 1, section: 0)
        self.tableView.insertRows(at: [inserIndexPath], with: .automatic)
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [firstIndexPath], with: .automatic)
    }
}
