import Foundation

class Record: Equatable {
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
    
    //isDelete to mysql row.
    
    var userCellLB :String?
    
    /*  1.發文章前，先去server上取得 文章ID。
     */
}
