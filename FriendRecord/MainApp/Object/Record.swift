import Foundation

class Record: Equatable ,Codable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs === rhs
    }
    
    var recordID :Double?//文章ID
    var recordDate :String?//發文日期
    var recordSendUser :String? //發文者帳號
    var userNickName :String?//發文者名字
    var recordFileName :String?//錄音檔名
    var recordText :String?//文章標內容
    var recordTime :String?//錄音時間
    
    var goodSum :Double?//讚數
    var Good_user :String?//是否已按讚
    
    //isDelete to mysql row.
    var isDelete :Int?
    var userCellLB :String?
    
    /*  1.發文章前，先去server上取得 文章ID。
     */
}
