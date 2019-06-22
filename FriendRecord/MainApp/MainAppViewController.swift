import UIKit

class MainAppViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let userCellValue = Record()
        userCellValue.userCellLB = "發個錄音帶給大家聽聽~"
        Manager.recordDataUser.append(userCellValue)
        self.tableViewData = [Manager.recordDataUser,[]]
        print("tableViewData[0]：\(self.tableViewData[0].count)")
        print("tableViewData[1]：\(self.tableViewData[1].count)")
        print("Manager.recordDataUser：\(Manager.recordDataUser.count)")
        print("Manager.recordData：\(Manager.recordData.count)")
        
        if Manager.recordData.count > 0 {
            self.tableViewData[1] = Manager.recordData
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPoRecordBT: UIButton!
    
    //var record :[Record] = []
    var tableViewData = [Manager.recordDataUser,[Record]()]
    
    var userSelectRow :Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mydelegate = self
        
        Manager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //check User Photo is new or downLoad to server.
        let userPhoto = UserDefaults.standard
        let isUserPhoto = userPhoto.bool(forKey: "isUserPhoto")
        guard isUserPhoto == false else {
            let indexpath = IndexPath(row: 0, section: 0)
            self.tableView.reloadRows(at: [indexpath], with: .automatic)
            self.tableView.reloadData()
            //new user Photo.
            let userDataDefault = UserDefaults.standard
            userDataDefault.bool(forKey: "isUserPhoto")
            userDataDefault.set(false , forKey: "isUserPhoto")
            return
        }
    }
    
    @IBAction func test(_ sender: Any) {
        print("Manager.recordData.count:\(Manager.recordData.count)")
        print("self.tableViewData[1]:\(self.tableViewData[1].count)")
    }
    
}

extension MainAppViewController :UITableViewDataSource ,UITableViewDelegate{
    //MARK:UITableDataSource protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! MyUserTableViewCell
            cell.imageUserPhoto.layer.cornerRadius = cell.imageUserPhoto.bounds.height / 2
            //record file path URL.
            let recordData = UserDefaults.standard
            if let recordDataEmailHead = recordData.string(forKey: "emailHead") {
                cell.imageUserPhoto.image = Manager.shared.userPhotoRead(jpg: recordDataEmailHead)
            }
            cell.showLB.text = self.tableViewData[indexPath.section][indexPath.row].userCellLB
            //Auto change cell hight.
            self.tableView.rowHeight = cell.showLB.bounds.height + 50
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! MyRecordTableViewCell
            //cell.mainLB.text = Manager.recordData[indexPath.row].recordText
           cell.mainLB.text  = self.tableViewData[indexPath.section][indexPath.row].recordText

            if let imageName = self.tableViewData[indexPath.section][indexPath.row].recordSendUser {
                let imageNameChange = imageName.split(separator: "@")
                let name = "\(imageNameChange[0])"
                cell.sendImage.image = Manager.shared.userPhotoRead(jpg: name)
                cell.sendImage.layer.cornerRadius = cell.sendImage.bounds.height / 2
            }
            cell.sendUserNameLB.text = Manager.recordData[indexPath.row].userNickName
            cell.sendRecordDateLB.text = Manager.recordData[indexPath.row].recordDate
            
            //Auto change cell hight.
            self.tableView.rowHeight = cell.mainView.bounds.height + 30
            cell.mainView.layer.cornerRadius = 10
            cell.mainView.layer.masksToBounds = true
            cell.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.5)
           return cell
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    //MARK: Protocol - tableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let recordgovc = self.storyboard?.instantiateViewController(withIdentifier: "recordgoVC") as! RecordGoViewController
            recordgovc.delegate = self
            self.present(recordgovc, animated: true, completion: nil)
        } else {
            Manager.indexPath = indexPath.row
        }
    }
    //MARK: func - tableView Cell separatorInset.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }

}

extension MainAppViewController :RecordGoViewControllerDelegate {
    //MARK: Protocol - RecordGoViewControllerDelegate.
    //if user send new record pen , this delegate tell MainVC tableView insert and reload Row.
    func sendRecordPen(Record: Record) {
        print("RecordGoViewControllerDelegate - sendRecordPen")
        if let selectIndex = Manager.recordData.firstIndex(of: Record) {
            self.tableViewData[1].insert(Record, at: 0)
            print("tableViewData[0]：\(self.tableViewData[0].count)")
            print("tableViewData[1]：\(self.tableViewData[1].count)")
            print("Manager.recordDataUser：\(Manager.recordDataUser.count)")
            print("Manager.recordData：\(Manager.recordData.count)")
            print("selectIndex:\(selectIndex)")
            //change indexPath
            let selectIndexPath = IndexPath(row: selectIndex, section: 1)
            //tableView Reload.
            self.tableView.insertRows(at: [selectIndexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
}

extension MainAppViewController: MyAppDelegate {
    func updateManagerRecordData() {
        print("MyAppDelegate - updateManagerRecordData")
        
        //Analysis email to phtot.
        for photoData in Manager.recordData{
            let data = photoData.recordSendUser
            
            guard let dataChanage = data else {
                print("********** AppDelegate func downLoadRecordPenUserPhoto error. **********")
                return
            }
            let imageNameChange = dataChanage.split(separator: "@")
            let fileName = "\(imageNameChange[0])"
            
            print("\(fileName)")
            //Download photo func.
            Manager.shared.downLoadUserPhoto(fileName: fileName)
        }
        
        
        self.tableViewData[1] = Manager.recordData

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MainAppViewController :ManagerDelegate {
    func finishDownLoadUserPhoto() {
        print("ManagerDelegate - finishDownLoadUserPhoto")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
