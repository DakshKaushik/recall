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
    var content: String?
    var date: Date
    var type: String
    var data:Data?
    var isPinned: Bool
    var customName: String?
    init(id: UUID = UUID(), content: String?, date: Date, type: String,data:Data?, isPinned: Bool = false, customName: String? = nil) {
            self.id = id
            self.content = content
            self.date = date
            self.type = type
            self.data=data
            self.isPinned = isPinned
            self.customName = customName
        }
    var displayName: String {
        if let customName = customName, !customName.isEmpty {
            return customName
        }
        if type == "Image" {
            return "Image"
        }
        return content?.prefix(30).trimmingCharacters(in: .whitespacesAndNewlines) ?? "Empty"
    }
    
    var characterCount: Int {
        return content?.count ?? 0
    }
    
    var wordCount: Int {
        return content?.split(separator: " ").count ?? 0
    }
}
