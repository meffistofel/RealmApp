//
//  Task.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}
//model
class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    var tasks = List<Task>()
}
