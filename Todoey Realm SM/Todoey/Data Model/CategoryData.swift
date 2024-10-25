

import Foundation
import RealmSwift

class CategoryData: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let todoDatas = List<TodoData>()
}
