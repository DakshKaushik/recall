//
//  dataModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 17/04/25.
//

import Foundation
import SwiftUI
struct ClipboardItem:Identifiable,Hashable,Codable{
    var id=UUID()
    var content: String
    var date: Date
    var type: String
    init(id: UUID = UUID(), content: String, date: Date, type: String) {
            self.id = id
            self.content = content
            self.date = date
            self.type = type
        }
    var characterCount: Int {
        return content.count
    }
    
    var wordCount: Int {
        return content.split(separator: " ").count
    }
}
