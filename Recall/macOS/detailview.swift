//
//  clipboardViewModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 19/04/25.
//
import SwiftUI
import AppKit

struct DetailView: View {
    let selectedItem: ClipboardItem?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if let item = selectedItem {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with type info
                    HStack {
                        Image(systemName: iconFor(type: item.type))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(colorFor(type: item.type))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading) {
                            Text(item.type)
                                .font(.headline)
                            
                            Text(item.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Action buttons
                        Button(action: { NSPasteboard.general.setString(item.content, forType: .string) }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color(colorScheme == .dark ? NSColor.windowBackgroundColor : NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Content area
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        Text(item.content)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(colorScheme == .dark ? NSColor.textBackgroundColor : NSColor.textBackgroundColor).opacity(0.6))
                            .cornerRadius(8)
                    }
                    
                    // Statistics section
                    VStack(alignment: .leading) {
                        Text("Statistics")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 20) {
                            StatBadge(
                                title: "Characters",
                                value: "\(item.characterCount)",
                                icon: "character.textbox"
                            )
                            
                            StatBadge(
                                title: "Words",
                                value: "\(item.wordCount)",
                                icon: "text.word.spacing"
                            )
                            
                            StatBadge(
                                title: "Lines",
                                value: "\(item.content.components(separatedBy: .newlines).count)",
                                icon: "list.bullet"
                            )
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Clipboard Details")
            .background(Color(NSColor.windowBackgroundColor))
        } else {
            // Empty state
            VStack(spacing: 16) {
                Image(systemName: "clipboard")
                    .font(.system(size: 56))
                    .foregroundColor(.secondary)
                
                Text("Select an item from the list")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Clipboard details will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Item Details")
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    // Helper functions
    func iconFor(type: String) -> String {
        switch type.lowercased() {
        case let t where t.contains("image"): return "photo"
        case let t where t.contains("url") || t.contains("link"): return "link"
        case let t where t.contains("formatted"): return "textformat"
        case let t where t.contains("code"): return "chevron.left.forwardslash.chevron.right"
        default: return "doc.text"
        }
    }
    
    func colorFor(type: String) -> Color {
        switch type.lowercased() {
        case let t where t.contains("image"): return .blue
        case let t where t.contains("url") || t.contains("link"): return .green
        case let t where t.contains("formatted"): return .orange
        case let t where t.contains("code"): return .purple
        default: return .accentColor
        }
    }
}
