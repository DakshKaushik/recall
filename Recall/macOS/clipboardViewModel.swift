//
//  clipboardViewModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 11/04/25.
//

import Foundation
import AppKit
class ClipboardViewModel:ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
        
        private var lastChangeCount: Int
        private var timer: Timer?
        
        init() {
            // Remember the current state of the clipboard
            lastChangeCount = NSPasteboard.general.changeCount
            // Start watching for changes
            startMonitoring()
        }
        
        func startMonitoring() {
            // Check clipboard every half second
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.checkClipboard()
            }
        }
        
        private func checkClipboard() {
            let pasteboard = NSPasteboard.general
            
            // Has the clipboard changed?
            if pasteboard.changeCount != lastChangeCount {
                lastChangeCount = pasteboard.changeCount
                
                // Try to get text from clipboard
                if let string = pasteboard.string(forType: .string) {
                    // Create a new clipboard item
                    let newItem = ClipboardItem(
                        content: string,
                        date: Date(),
                        type: string.contains("\n") ? "Text (Formatted)" : "Text",
                    )
                    
                    // Add to our list
                    DispatchQueue.main.async {
                        self.clipboardItems.insert(newItem, at: 0)
                    }
                }
            }
        }
    
}
