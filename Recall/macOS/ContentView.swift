import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = ClipboardViewModel()
    @State private var selectedItemId: UUID?
    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme
    
    init(viewModel: ClipboardViewModel = ClipboardViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return viewModel.clipboardItems
        } else {
            return viewModel.clipboardItems.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            
            VStack(spacing: 0) {
               
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(8)
                .background(Color(NSColor.textBackgroundColor).opacity(0.5))
                .cornerRadius(8)
                .padding([.horizontal, .top])
                
                // List of clipboard items
                List(filteredItems, selection: $selectedItemId) { item in
                    HStack(spacing: 12) {
                        // Icon based on content type
                        Image(systemName: iconFor(type: item.type))
                            .foregroundColor(colorFor(type: item.type))
                            .frame(width: 28, height: 28)
                            .background(colorFor(type: item.type).opacity(0.1))
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.content.prefix(30))
                                .lineLimit(1)
                                .font(.system(size: 14, weight: .medium))
                            
                            HStack {
                                Text(item.type)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(timeAgoString(from: item.date))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .tag(item.id)
                }
                .listStyle(.sidebar)
            }
            .frame(minWidth: 280)
            
        } detail: {
           
            if let selectedId = selectedItemId,
               let selectedItem = viewModel.clipboardItems.first(where: { $0.id == selectedId }) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack {
                            Image(systemName: iconFor(type: selectedItem.type))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(colorFor(type: selectedItem.type))
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading) {
                                Text(selectedItem.type)
                                    .font(.headline)
                                
                                Text(selectedItem.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                     
                            Button(action: { NSPasteboard.general.setString(selectedItem.content, forType: .string) }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(colorScheme == .dark ? NSColor.windowBackgroundColor : NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                        
                     
                        VStack(alignment: .leading) {
                            Text("Content")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            Text(selectedItem.content)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(colorScheme == .dark ? NSColor.textBackgroundColor : NSColor.textBackgroundColor).opacity(0.6))
                                .cornerRadius(8)
                        }
                        
                
                        VStack(alignment: .leading) {
                            Text("Statistics")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            HStack(spacing: 20) {
                                StatBadge(
                                    title: "Characters",
                                    value: "\(selectedItem.characterCount)",
                                    icon: "character.textbox"
                                )
                                
                                StatBadge(
                                    title: "Words",
                                    value: "\(selectedItem.wordCount)",
                                    icon: "text.word.spacing"
                                )
                                
                                StatBadge(
                                    title: "Lines",
                                    value: "\(selectedItem.content.components(separatedBy: .newlines).count)",
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
        .navigationSplitViewStyle(.balanced)
    }

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
    
    func timeAgoString(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)h ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)m ago"
        } else {
            return "Just now"
        }
    }
}

struct StatBadge: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2.bold())
        }
        .frame(minWidth: 100)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

#Preview {
    let mockViewModel = ClipboardViewModel()
    mockViewModel.clipboardItems = [
        ClipboardItem(content: "Sample clipboard text that might be long enough to show line wrapping", date: Date(), type: "Text"),
        ClipboardItem(content: "Another clipboard item with more content", date: Date().addingTimeInterval(-3600), type: "Text (Formatted)"),
        ClipboardItem(content: "https://www.apple.com", date: Date().addingTimeInterval(-86400), type: "URL"),
        ClipboardItem(content: "let x = 10", date: Date().addingTimeInterval(-172800), type: "Code")
    ]
    
    return ContentView(viewModel: mockViewModel)
}
