import Foundation

class Message : Equatable,Codable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs === rhs
    }
    
    var recordID :Double?
    var messageUser :String?
    var messageNickName :String?
    var message :String?
    var penDate :String?
    var messageSum :Double?

}
