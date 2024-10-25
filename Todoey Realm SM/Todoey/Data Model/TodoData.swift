

import Foundation
import RealmSwift

class TodoData: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var checked: Bool = false
    @objc dynamic var createdAt: Date?
    var parentCategory = LinkingObjects(fromType: CategoryData.self, property: "todoDatas")
}
