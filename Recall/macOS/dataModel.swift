//
//  dataModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 17/04/25.
//

import Foundation

struct ClipboardItem:Identifiable{
    var id=UUID()
    var content: String
    var date: Date
    var type: String
    
    var characterCount: Int {
        return content.count
    }
    
    var wordCount: Int {
        return content.split(separator: " ").count
    }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
}
