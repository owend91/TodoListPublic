//
//  Group.swift
//  Todo
//
//  Created by David Owen on 9/2/20.
//  Copyright © 2020 David Owen. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
    @objc dynamic var color : String = ""
    
}

