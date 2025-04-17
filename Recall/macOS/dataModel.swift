//
//  dataModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 17/04/25.
//

import Foundation
import SwiftUI
struct ClipboardItem:Identifiable,Hashable{
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
}
