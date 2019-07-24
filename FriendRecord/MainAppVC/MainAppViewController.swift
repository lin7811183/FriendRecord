import UIKit
import AVKit
import Firebase
import FirebaseMessaging

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
    @IBOutlet weak var recordPenShowMode: UIBarButtonItem!
    var recordPenShowMode2 :UIBarButtonItem!
    @IBOutlet weak var goToTop: UIButton!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    
    var tableViewData = [Manager.recordDataUser,[Record]()]
    
    var userSelectRow :Int!
    
    var refreshControl :UIRefreshControl!
    
    var loadDataArray :[Record]!
    var isGoodType :Bool!
    var goodIndexPath :Int!
    var reloadIndexPath :IndexPath!
    
    var isPiayer = false
    //建立AudioRecorder元件
    var recordPlayer :AVAudioPlayer?
    var recordIndexPath :IndexPath!
    var oldRecordIndexPath :IndexPath!
    
    var pushIndex :IndexPath!
    
    let transiton = SlideInTransition()

    var isSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.largeTitleDisplayMode = .never
        // 預載資料
        self.loadingActivity.startAnimating()
        Manager.shared.downLoadRecordPen()
        Manager.shared.downLoadUserPhoto()
        Manager.shared.userOnline()
        
        // add navigationItem Logo item
//        let logo = UIImage(named: "Logo")
//        let imageView = UIImageView(image:logo)
//        self.navigationItem.titleView = imageView
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mydelegate = self
        
        Manager.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "更新留言板")
        self.refreshControl.addTarget(self, action: #selector(self.downLoadRecordPen), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
//        self.goToTop.layer.borderWidth = 1
//        self.goToTop.layer.borderColor = UIColor.black.cgColorxw
//        self.goToTop.layer.cornerRadius = self.goToTop.frame.height / 2

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopOldRecordMuice()
        Manager.recordDataUser.removeAll()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.stopOldRecordMuice()
    }
    /*------------------------------------------------------------ Functions. ------------------------------------------------------------*/
    //MARK: func - DownLoad Record Pen.
    @objc func downLoadRecordPen() {
        print("downLoadRecordPen")
        Manager.shared.downLoadRecordPen()
        Manager.shared.downLoadUserPhoto()
    }
    //MARK: func - Go to TableView Top.
    @IBAction func goToTableViewTop(_ sender: Any) {
        print("********** User Record Pen Go to Top. **********")
        let topIndex = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topIndex, at: .top, animated: true)
    }
    //MARK: func - Change record pen show mode.
    @IBAction func showRecordPenShow(_ sender: UISegmentedControl) {
        self.loadingActivity.startAnimating()
        if sender.selectedSegmentIndex == 0 {
            //全音模式
            Manager.shared.downLoadRecordPen()
        } else if sender.selectedSegmentIndex == 1 {
            //好友模式
            Manager.shared.downLoadRecordPenFriend()
        }
        print(sender.selectedSegmentIndex)
    }
    //MARK: func - Show friend Menu.
    @IBAction func friendMenu(_ sender: Any) {
        guard let friendMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "friendmenuVC") as? FriendMenuViewController else { return }
        friendMenuVC.modalPresentationStyle = .overCurrentContext
        friendMenuVC.transitioningDelegate = self
        self.present(friendMenuVC, animated: true)
    }
    //MARK: func - Stop old Record Muice.
    func stopOldRecordMuice() {
        //Stop old Record pen muice.
        if self.isPiayer == true {
            if let indexPath = self.oldRecordIndexPath {
                print("user is out MainAppVC.")
                let oldcurrentCell = self.tableView.cellForRow(at: indexPath) as! MyRecordTableViewCell
                //oldcurrentCell.sendImage.layer.borderWidth = 0
                oldcurrentCell.sendImage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                self.recordPlayer?.stop()
                self.isPiayer = false
            }
        }
    }
    //MARK: func - Search User
    @IBAction func searchUser(_ sender: Any) {
        if self.isSearch == false {
            let searchBar = UISearchBar()
            searchBar.placeholder = "Test ..."
            self.navigationItem.titleView = searchBar
            self.navigationItem.leftBarButtonItems = []
            
            self.isSearch = true
        } else {
            self.navigationItem.titleView = nil
            self.recordPenShowMode2 = UIBarButtonItem()
            self.navigationItem.leftBarButtonItems = [self.recordPenShowMode2]
            self.isSearch = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "push" {
            let leavemessageVC = segue.destination as! LeaveMessageViewController
            let currentCell = self.tableView.cellForRow(at: self.pushIndex!) as! MyRecordTableViewCell
            leavemessageVC.recordId = Int(currentCell.RecordID)
            leavemessageVC.messageIndexPath = self.pushIndex
            leavemessageVC.recordSendUser = self.tableViewData[1][self.pushIndex.row].recordSendUser
            leavemessageVC.recorduserNickName = self.tableViewData[1][self.pushIndex.row].userNickName
            leavemessageVC.recordFileName = self.tableViewData[1][self.pushIndex.row].recordFileName
            leavemessageVC.formVC = 0
            
            leavemessageVC.delegate = self
        }
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
                let fileName = Manager.shared.emailChangeHead(email: imageName)
                cell.sendImage.image = Manager.shared.userPhotoRead(jpg: fileName)
                
                cell.sendImage.tag = indexPath.row
                
                let action = UITapGestureRecognizer(target: self, action: #selector(self.player(sender:)))
                cell.sendImage.addGestureRecognizer(action)
                cell.sendImage.isUserInteractionEnabled = true
                
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
            
            cell.goodSumLB.text = "\(Int(self.tableViewData[indexPath.section][indexPath.row].goodSum ?? 0))"
            cell.messageSumLB.text = "\(Int(self.tableViewData[indexPath.section][indexPath.row].messageSum ?? 0))"
            
            
            cell.RecordID = self.tableViewData[indexPath.section][indexPath.row].recordID
            cell.recordIndexPath = indexPath

            cell.delegate = self
            cell.delegate2 = self

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
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let userData = UserDefaults.standard
        let recordPenUser = userData.string(forKey: "email")
        
        let data = self.tableViewData[1][indexPath.row]
        
        guard let user = data.recordSendUser else {
            let none = UITableViewRowAction(style: .default, title: "None") { (action, indexPath) in
            }
            return [none]
        }
        guard recordPenUser != user else {
            let deleteAction = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in

                self.tableViewData[1].remove(at: indexPath.row)
                Manager.recordData.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.rectForRow(at: indexPath)
                Manager.shared.deleteRecordPen(recordID: Int(data.recordID!))
            }
            deleteAction.backgroundColor = UIColor.red
            return [deleteAction]
        }
        let action = UITableViewRowAction(style: .default, title: "檢舉") { (action, indexPath) in
            Manager.shared.okAlter(vc: self, title: "按下確認後，送出檢舉", message: "後續客服會進行查證，謝謝")
        }
        action.backgroundColor = UIColor.gray
        return [action]
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
    //MARK: func - player.
    @objc func player(sender :UITapGestureRecognizer) {
        // Check if player!?
        if self.isPiayer ==  true {
            //stop old player task.
            let oldcurrentCell = self.tableView.cellForRow(at: self.oldRecordIndexPath) as! MyRecordTableViewCell
            //oldcurrentCell.sendImage.layer.borderWidth = 0
            oldcurrentCell.sendImage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            
            guard let imageView = sender.view as? UIImageView  else {
                return
            }
            //stop now player task.
            let row = imageView.tag
            let indexPath = IndexPath(row: row, section: 1)
            self.recordIndexPath = indexPath
            self.oldRecordIndexPath = indexPath
            let currentCell = self.tableView.cellForRow(at: indexPath) as! MyRecordTableViewCell
            //currentCell.sendImage.layer.borderWidth = 0
            currentCell.sendImage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            
            //Record stop Player.
            self.recordPlayer?.stop()
            print("********** Stop player Record. **********")
            
            self.isPiayer = false
        } else {
            guard let imageView = sender.view as? UIImageView  else {
                return
            }
            let row = imageView.tag
            let indexPath = IndexPath(row: row, section: 1)
            self.recordIndexPath = indexPath
            self.oldRecordIndexPath = indexPath
            let currentCell = self.tableView.cellForRow(at: indexPath) as! MyRecordTableViewCell
            
            let filePathURL = Manager.shared.fileDocumentsPath(fileName: self.tableViewData[1][indexPath.row].recordFileName!)
            //Play Record.
            self.recordPlayer = try? AVAudioPlayer(contentsOf: filePathURL)
            self.recordPlayer?.numberOfLoops = 0
            self.recordPlayer?.prepareToPlay()
            self.recordPlayer?.delegate = self
            
            //Create Audio Session.
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.playback)
            
            //Record Player.
            self.recordPlayer?.play()
            print("********** Star player Record. **********")
            
            //currentCell.sendImage.layer.borderWidth = 2
            //currentCell.sendImage.layer.borderColor = UIColor.green.cgColor
            
            //播放進度條:
            let imageCirclePathLayer = CAShapeLayer()
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: currentCell.sendImage.frame.size.width / 2, y: currentCell.sendImage.frame.size.height / 2), radius: (currentCell.sendImage.frame.size.width - 1.5) / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
            
            imageCirclePathLayer.path = circlePath.cgPath
            imageCirclePathLayer.fillColor = UIColor.clear.cgColor
            imageCirclePathLayer.strokeColor = UIColor(named: "MyColor3")?.cgColor
            imageCirclePathLayer.lineWidth = 3.0
            imageCirclePathLayer.strokeEnd = 1.0
            currentCell.sendImage.layer.addSublayer(imageCirclePathLayer)
            
            let time = self.tableViewData[1][indexPath.row].recordTime
            let animationTime = self.playerTimeChange(time: time!)
            self.setProgressWithAnimation(imageCircle: imageCirclePathLayer, duration: animationTime, value: 1.0)
            
            self.isPiayer = true
        }
    }
    //MARK: func - 播放進度條動畫
    func setProgressWithAnimation(imageCircle :CAShapeLayer, duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        imageCircle.strokeEnd = CGFloat(value)
        imageCircle.add(animation, forKey: "animateprogress")
    }
    //MARK: func - Record Muice timer change
    func playerTimeChange(time :String) -> Double {
        let timeData = time.split(separator: ":")
        let minute = Double(timeData[0])! * 60.0
        let second = Double(timeData[1])!
        
        let totalTime = minute + second - 0.25
        return totalTime
    }
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
            
            self.tableView.reloadRows(at: [self.reloadIndexPath], with: .fade)
            
            print("Stop Record.")
            let currentCell = tableView.cellForRow(at: self.reloadIndexPath) as! MyRecordTableViewCell
            //currentCell.sendImage.layer.borderWidth = 0
            currentCell.sendImage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.tableView.isScrollEnabled = true
            self.recordPlayer?.stop()
        } else {
            sender.setImage(UIImage(named: "isLike.png"), for: .normal)
            self.tableViewData[1][self.goodIndexPath].Good_user = nil
            self.tableViewData[1][self.goodIndexPath].goodSum! -= 1.0
            Manager.recordData[self.goodIndexPath] = self.tableViewData[1][self.goodIndexPath]
            
            self.tableView.reloadRows(at: [self.reloadIndexPath], with: .fade)
            
            self.recordPlayer?.stop()
            print("Stop Record.")
            
            let currentCell = tableView.cellForRow(at: self.reloadIndexPath) as! MyRecordTableViewCell
            //currentCell.sendImage.layer.borderWidth = 0
            currentCell.sendImage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//            self.tableView.isScrollEnabled = true
//            self.recordPlayer?.stop()
        }
    }
}

extension MainAppViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transiton.isPresenting = true
        return transiton
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transiton.isPresenting = false
        return transiton
    }
}


extension MainAppViewController :AVAudioPlayerDelegate {
    //MARK: Protocol - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            let currentCell = self.tableView.cellForRow(at: self.recordIndexPath)  as! MyRecordTableViewCell
            currentCell.sendImage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.recordPlayer?.stop()
            print("********** Stop player Record. **********")
            currentCell.sendImage.layer.borderWidth = 0
            self.isPiayer = false
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
            UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCurlUp, animations: { self.tableView.reloadData() })
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
            
            // left out the unnecessary syntax in the completion block and the optional completion parameter
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {self.tableView.reloadData() })
            self.loadingActivity.stopAnimating()
        }
    }
    //MARK: Protocol - ManagerDelegate by Manager.
    func finishDownLoadUserPhoto() {
        print("ManagerDelegate - finishDownLoadUserPhoto")
        DispatchQueue.main.async {
            UIView.transition(with: self.tableView, duration: 1, options: .transitionCrossDissolve, animations: { self.tableView.reloadData()
                
            })
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

extension MainAppViewController :MyRecordTableViewCellDelegate2 {
    func pushIndexPath(indexPath: IndexPath) {
        print("MyRecordTableViewCellDelegate2 - pushIndexPath")
        self.pushIndex = indexPath
    }
}

extension MainAppViewController :LeaveMessageViewControllerDelegate {
    func updateMessageSum() {
        print("LeaveMessageViewControllerDelegate - updateMessageSum")
        self.tableView.reloadData()
    }
}
