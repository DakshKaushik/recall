//
//  clipboardViewModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 11/04/25.
//

import Foundation
import AppKit

class ClipboardViewModel: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    
    private var lastChangeCount: Int
    private var timer: Timer?
    private let storageURL: URL
    
    init() {
        lastChangeCount = NSPasteboard.general.changeCount
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupportURL.appendingPathComponent("Recall")

        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        storageURL = appDirectory.appendingPathComponent("clipboard_history.json")
        loadClipboardItems()

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
            
            // Try to get image from clipboard first
            if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage,
               let tiffData = image.tiffRepresentation {
                // Create a new clipboard item for image
                let newItem = ClipboardItem(
                    content: "Image",
                    date: Date(),
                    type: "Image",
                    data: tiffData,
                    isPinned: false,
                    customName: nil
                )
                
                // Add to our list
                DispatchQueue.main.async {
                    self.clipboardItems.insert(newItem, at: 0)
                    self.saveClipboardItems()
                }
            }
            // If no image, try to get text
            else if let string = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty {
                // Create a new clipboard item for text
                let newItem = ClipboardItem(
                    content: string,
                    date: Date(),
                    type: "Text",
                    data: nil,
                    isPinned: false,
                    customName: nil
                )
                
                // Add to our list
                DispatchQueue.main.async {
                    self.clipboardItems.insert(newItem, at: 0)
                    self.saveClipboardItems()
                }
            }
        }
    }
    
    func removeItem(with id: UUID) {
        clipboardItems.removeAll { $0.id == id }
        saveClipboardItems()
    }
    
    func copyItem(with id: UUID) {
        if let item = clipboardItems.first(where: { $0.id == id }) {
            if item.type == "Image", let imageData = item.data {
                // Handle image copy
                if let image = NSImage(data: imageData) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects([image])
                }
            } else {
                // Handle text copy
                NSPasteboard.general.setString(item.content ?? "", forType: .string)
            }
            
            let newItem = ClipboardItem(
                content: item.content,
                date: Date(),
                type: item.type,
                data: item.data
            )
            DispatchQueue.main.async {
                self.clipboardItems.insert(newItem, at: 0)
                self.saveClipboardItems()
            }
        }
    }
    
    func pinItem(with id: UUID) {
        if let index = clipboardItems.firstIndex(where: { $0.id == id }) {
            clipboardItems[index].isPinned.toggle()
            saveClipboardItems()
        }
    }
    
    func renameItem(with id: UUID, newName: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == id }) {
            clipboardItems[index].customName = newName.isEmpty ? nil : newName
            saveClipboardItems()
        }
    }
    
    // Save clipboard items to disk
    private func saveClipboardItems() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(clipboardItems)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save clipboard items: \(error.localizedDescription)")
        }
    }

    private func loadClipboardItems() {
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: storageURL.path) {
                let data = try Data(contentsOf: storageURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                clipboardItems = try decoder.decode([ClipboardItem].self, from: data)
            }
        } catch {
            print("Failed to load clipboard items: \(error.localizedDescription)")
        }
    }
}
