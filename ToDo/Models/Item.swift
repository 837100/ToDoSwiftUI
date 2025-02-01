//
//  Item.swift
//  ToDoApp
//
//  Created by SG on 1/17/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    
    @Attribute(.unique) var todoId: UUID
    var todo: String
    var endDate: Date
    var todoDetails: String
    var isToggled: Bool = false
    var importance: Int = 0
    var createdAt: Date = Date()
    var category: String = ""
    
    init(todo: String , endDate: Date, todoId: UUID, todoDetails: String, importance: Int, createdAt: Date = Date()) {
        self.todo = todo
        self.endDate = endDate
        self.todoId = todoId
        self.todoDetails = todoDetails
        self.importance = importance
        self.createdAt = createdAt
    }
}
