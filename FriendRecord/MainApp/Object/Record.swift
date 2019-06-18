import Foundation

class Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs === rhs
    }
    
    var recordSendUser :String?
    var recordFileName :String?
    var recordText :String?
    var recordTime :String?
    var recordDate :Date?
    var userNickName :String?
    
    
    var userCellLB :String?
}
