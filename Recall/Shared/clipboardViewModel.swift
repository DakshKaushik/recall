//
//  clipboardViewModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 11/04/25.
//

import Foundation
class ClipboardViewModel:ObservableObject {
    @Published var clipboardHistory:[String] = []
    private let clipboardService:ClipboardService
    init(clipboardService:ClipboardService){
        self.clipboardService = clipboardService
    }
    func fetchClipboard(){
      
    }
    
}
