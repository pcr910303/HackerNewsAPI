
import Foundation

protocol Item {
    var id: Int { get }
    var time: Date { get }
    var author: User { get }
}
