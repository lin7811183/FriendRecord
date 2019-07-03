import UIKit
import AVKit

class MainAppViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let userCellValue = Record()
        userCellValue.userCellLB = "發個錄音帶給大家聽聽~"
        Manager.recordDataUser.append(userCellValue)
        self.tableViewData = [Manager.recordDataUser,[]]
//        print("tableViewData[0]：\(self.tableViewData[0].count)")
//        print("tableViewData[1]：\(self.tableViewData[1].count)")
//        print("Manager.recordDataUser：\(Manager.recordDataUser.count)")
//        print("Manager.recordData：\(Manager.recordData.count)")
        
        if Manager.recordData.count > 0 {
            self.tableViewData[1] = Manager.recordData
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPoRecordBT: UIButton!
    
    var tableViewData = [Manager.recordDataUser,[Record]()]
    
    var userSelectRow :Int!
    
    var refreshControl:UIRefreshControl!
    
    var loadDataArray :[Record]!
    var isGoodType :Bool!
    var goodIndexPath :Int!
    var reloadIndexPath :IndexPath!
    
    var isPiayer = false
    //建立AudioRecorder元件
    var recordPlayer :AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mydelegate = self
        
        Manager.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "更新留言板")
        self.refreshControl.addTarget(self, action: #selector(self.downLoadRecordPen), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
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
    /*------------------------------------------------------------ Function. ------------------------------------------------------------*/
    //MARK: func - DownLoad Record Pen.
    @objc func downLoadRecordPen() {
        print("downLoadRecordPen")
        Manager.shared.downLoadRecordPen()
        Manager.shared.downLoadUserPhoto()
    }
        
}

/*------------------------------------------------------------ Protocol. ------------------------------------------------------------*/
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
            cell.selectionStyle = .none//讓選取顏色不會出現
            
            return cell
        } else {
            let cellIdentifier = self.cellStyle()
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyRecordTableViewCell
            
            cell.recordPenLB.text  = self.tableViewData[indexPath.section][indexPath.row].recordText
            
            if let imageName = self.tableViewData[indexPath.section][indexPath.row].recordSendUser {
                let imageNameChange = imageName.split(separator: "@")
                let name = "\(imageNameChange[0])"
                cell.sendImage.image = Manager.shared.userPhotoRead(jpg: name)
                cell.sendImage.layer.cornerRadius = cell.sendImage.bounds.height / 2
            }

            cell.sendUserNameLB.text = self.tableViewData[indexPath.section][indexPath.row].userNickName
            
            let getDate = Manager.shared.dateChange(date: self.tableViewData[indexPath.section][indexPath.row].recordDate!)
            cell.sendRecordDateLB.text = getDate

            if let data = self.tableViewData[indexPath.section][indexPath.row].Good_user {
                cell.recordPenGoodBT.setImage(UIImage(named: "isLike.png"), for: .normal)
            } else {
                cell.recordPenGoodBT.setImage(UIImage(named: "Like.png"), for: .normal)
            }

            cell.goodSumLB.text = "x \(Int(self.tableViewData[indexPath.section][indexPath.row].goodSum ?? 0))"

            cell.RecordID = self.tableViewData[indexPath.section][indexPath.row].recordID
//            cell.email = self.tableViewData[indexPath.section][indexPath.row].recordSendUser

            cell.delegate = self

            cell.recordPenGoodBT.addTarget(self, action: #selector(liked(sender:)), for: .touchUpInside)

            //Auto change cell hight.
            self.tableView.rowHeight = cell.sendImage.bounds.height + 45
            cell.selectionStyle = .none//讓選取顏色不會出現
            
            return cell
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    //MARK: Protocol - tableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            let recordgovc = self.storyboard?.instantiateViewController(withIdentifier: "recordgoVC") as! RecordGoViewController
            recordgovc.delegate = self
            self.present(recordgovc, animated: true, completion: nil)
            //選取後反灰消失.
            self.tableView.deselectRow(at: indexPath, animated: true)
        } else {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                print("Record Player indexPath error.")
                return
            }
            let currentCell = tableView.cellForRow(at: indexPath) as! MyRecordTableViewCell

            if self.isPiayer == false {

                let filePathURL = Manager.shared.fileDocumentsPath(fileName: self.tableViewData[1][indexPath.row].recordFileName!)
                //Play Record.
                self.recordPlayer = try? AVAudioPlayer(contentsOf: filePathURL)
                self.recordPlayer?.numberOfLoops = -1
                self.recordPlayer?.prepareToPlay()

                //Create Audio Session.
                let audioSession = AVAudioSession.sharedInstance()
                try? audioSession.setCategory(AVAudioSession.Category.playback)

                //Record Player.
                self.recordPlayer?.play()
                print("********** Star player Record. **********")
                
                currentCell.sendImage.layer.borderWidth = 5
                currentCell.sendImage.layer.borderColor = UIColor.green.cgColor
                
                self.isPiayer = true
                
                self.tableView.isScrollEnabled = false // Lock TableView not scroll.
                
                self.tableView.deselectRow(at: indexPath, animated: true) //選取後反灰消失.
            } else {
                self.recordPlayer?.stop()
                print("********** Stop player Record. **********")
                
                currentCell.sendImage.layer.borderWidth = 0
                
                self.isPiayer = false
                
                self.tableView.isScrollEnabled = true // Lock TableView not scroll.
                
                self.tableView.deselectRow(at: indexPath, animated: true) //選取後反灰消失.
            }
        }
    }
    //MARK: Protocol - tableview delegate canEditRowAt.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.tableView.isScrollEnabled == false {
            return false
        } else {
            return true
        }
    }
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if self.tableView.isScrollEnabled == false {
            return false
        } else {
            return true
        }
    }
    //MARK: func - tableview delegate - trailingSwipeActionsConfigurationForRowAt.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = self.action(at: indexPath)
        return UISwipeActionsConfiguration(actions: [action])
    }
    //MARK: func - tableview delegate - trailingSwipeActionsConfigurationForRowAt to action.
    func action(at indexPath :IndexPath) -> UIContextualAction {
        let data = self.tableViewData[1][indexPath.row]
        let action = UIContextualAction(style: .normal, title: "編輯") { (action, view, completion) in
            completion(true)
        }
        guard let user = data.recordSendUser else {
            return action
        }
    
        let userData = UserDefaults.standard
        let recordPenUser = userData.string(forKey: "email")
        
        guard recordPenUser != user else {
            action.image = UIImage(named: "edit.png")
            return action
        }
        action.image = UIImage(named: "waring.png")
        action.title = "檢舉"
        action.backgroundColor = UIColor.red
        return action
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(bitPattern: 5)
        }
        return tableView.sectionHeaderHeight
    }
    /*------------------------------------------------------------ TableView Protocol function. ------------------------------------------------------------*/
    //MARK: func - cell style.
    func cellStyle() -> String {
        let number = Int(arc4random())
        let cellName :String!
        if number % 3 == 0 {
            cellName = "recordCell"
            return cellName
        } else if number % 3 == 1 {
            cellName = "recordCell2"
            return cellName
        } else {
            cellName = "recordCell3"
            return cellName
        }
    }
    //MARK: func - uer give good button action.
    @objc func liked(sender: UIButton) {
        if let bool = self.isGoodType , bool == true {
            sender.setImage(UIImage(named: "Like.png"), for: .normal)
            self.tableViewData[1][self.goodIndexPath].Good_user = "UserIsLike"
            var goodsum = self.tableViewData[1][self.goodIndexPath].goodSum ?? 0.0
            goodsum += 1.0
            self.tableViewData[1][self.goodIndexPath].goodSum = goodsum
            Manager.recordData[self.goodIndexPath] = self.tableViewData[1][self.goodIndexPath]
            
            self.tableView.reloadRows(at: [self.reloadIndexPath], with: .right)
            
            print("Stop Record.")
            let currentCell = tableView.cellForRow(at: self.reloadIndexPath) as! MyRecordTableViewCell
            currentCell.sendImage.layer.borderWidth = 0
            self.tableView.isScrollEnabled = true
            self.recordPlayer?.stop()
        } else {
            sender.setImage(UIImage(named: "isLike.png"), for: .normal)
            self.tableViewData[1][self.goodIndexPath].Good_user = nil
            self.tableViewData[1][self.goodIndexPath].goodSum! -= 1.0
            Manager.recordData[self.goodIndexPath] = self.tableViewData[1][self.goodIndexPath]
            
            self.tableView.reloadRows(at: [self.reloadIndexPath], with: .right)
            
            self.recordPlayer?.stop()
            
            print("Stop Record.")
            let currentCell = tableView.cellForRow(at: self.reloadIndexPath) as! MyRecordTableViewCell
            currentCell.sendImage.layer.borderWidth = 0
            self.tableView.isScrollEnabled = true
            self.recordPlayer?.stop()
        }
    }
}

extension MainAppViewController :RecordGoViewControllerDelegate {
    //MARK: Protocol - RecordGoViewControllerDelegate.
    //if user send new record pen , this delegate tell MainVC tableView insert and reload Row.
    func sendRecordPen(Record: Record) {
        print("RecordGoViewControllerDelegate - sendRecordPen")
        if let selectIndex = Manager.recordData.firstIndex(of: Record) {
            self.tableViewData[1].insert(Record, at: 0)
//            print("tableViewData[0]：\(self.tableViewData[0].count)")
//            print("tableViewData[1]：\(self.tableViewData[1].count)")
//            print("Manager.recordDataUser：\(Manager.recordDataUser.count)")
//            print("Manager.recordData：\(Manager.recordData.count)")
//            print("selectIndex:\(selectIndex)")
            //change indexPath
            let selectIndexPath = IndexPath(row: selectIndex, section: 1)
            //tableView Reload.
            self.tableView.insertRows(at: [selectIndexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
}

extension MainAppViewController: MyAppDelegate {
    //MARK: Protocol - MyAppDelegate to AppDelegate.
    func updateManagerRecordData() {
        print("MyAppDelegate - updateManagerRecordData")
        
        //Analysis email to phtot.
        for photoData in Manager.recordData{
            let data = photoData.recordSendUser
            let record = photoData.recordFileName
            
            guard let dataChanage = data else {
                print("********** AppDelegate func downLoadRecordPenUserPhoto error. **********")
                return
            }
            
            guard let recordfile = record else {
                print("********** AppDelegate func downLoadRecordPenUserRecord error **********")
                return
            }
            
            let imageNameChange = dataChanage.split(separator: "@")
            let fileName = "\(imageNameChange[0])"
            
            //Download photo func.
            Manager.shared.downLoadUserPhoto(fileName: fileName)
            //Download Rcord File.
            Manager.shared.downLoadRcordFile(fileName: recordfile)
        }
        
        self.tableViewData[1] = Manager.recordData

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MainAppViewController :ManagerDelegate {
    func finishDownLoadUserRecordPen() {
        return
    }
    
    //MARK: Protocol - ManagerDelegate by Manager.
    func finishDownLoadRecordPen() {
        print("ManagerDelegate - finishDownLoadRecordPen")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            // 停止 refreshControl 動畫
            self.refreshControl.endRefreshing()
            
            
            //Analysis email to phtot.
            for photoData in Manager.recordData{
                let data = photoData.recordSendUser
                let record = photoData.recordFileName
                
                guard let dataChanage = data else {
                    print("********** MainAPP VC func downLoadRecordPenUserPhoto error. **********")
                    return
                }
                
                guard let recordfile = record else {
                    print("********** MainAPP VC func downLoadRecordPenUserRecord error **********")
                    return
                }
                
                let imageNameChange = dataChanage.split(separator: "@")
                let fileName = "\(imageNameChange[0])"
                
                //Download photo func.
                Manager.shared.downLoadUserPhoto(fileName: fileName)
                //Download Rcord File.
                Manager.shared.downLoadRcordFile(fileName: recordfile)
            }
            self.tableViewData[1] = Manager.recordData
            
            self.tableView.reloadData()
        }
    }
    
    //MARK: Protocol - ManagerDelegate by Manager.
    func finishDownLoadUserPhoto() {
        print("ManagerDelegate - finishDownLoadUserPhoto")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MainAppViewController :MyRecordTableViewCellDelegate {
    //MARK: Protocol - MyRecordTableViewCellDelegate.
    func updateIsGood(isGoodType: Bool, cell: UITableViewCell) {
        print("MyRecordTableViewCellDelegate - updateIsGood")
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        //  Do whatever you need to do with the indexPath.
        self.goodIndexPath = indexPath.row
        self.reloadIndexPath = indexPath
        self.isGoodType = isGoodType
    }
}

