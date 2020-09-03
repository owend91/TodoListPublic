//
//  Item.swift
//  Todo
//
//  Created by David Owen on 9/2/20.
//  Copyright © 2020 David Owen. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var complete: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
