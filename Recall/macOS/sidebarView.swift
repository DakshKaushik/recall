import SwiftUI
import AppKit

struct SidebarView: View {
    let items: [ClipboardItem]
    @Binding var selectedItemId: UUID?
    @Binding var searchText: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
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
            List(items, selection: $selectedItemId) { item in
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
    }
    
    // Helper functions
    func iconFor(type: String) -> String {
        switch type.lowercased() {
        case let t where t.contains("image"): return "photo"
        case let t where t.contains("url") || t.contains("link"): return "link"
        case let t where t.contains("formatted"): return "textformat"
        default: return "doc.text"
        }
    }
    
    func colorFor(type: String) -> Color {
        switch type.lowercased() {
        case let t where t.contains("image"): return .blue
        case let t where t.contains("url") || t.contains("link"): return .green
        case let t where t.contains("formatted"): return .orange
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
