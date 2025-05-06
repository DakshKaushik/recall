import SwiftUI
import AppKit

struct SidebarView: View {
    let items: [ClipboardItem]
    @Binding var selectedItemId: UUID?
    @Binding var searchText: String
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ClipboardViewModel
    @State private var editingItemId: UUID?
    @State private var editingName: String = ""
    @State private var hoveredItemId: UUID?
    
    var sortedItems: [ClipboardItem] {
        items.sorted { item1, item2 in
            if item1.isPinned && !item2.isPinned {
                return true
            }
            if !item1.isPinned && item2.isPinned {
                return false
            }
            return item1.date > item2.date
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .medium))
                
                TextField("Search clipboard items...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // List of items
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(sortedItems) { item in
                        ClipboardItemRow(
                            item: item,
                            isSelected: selectedItemId == item.id,
                            isHovered: hoveredItemId == item.id,
                            isEditing: editingItemId == item.id,
                            editingName: $editingName,
                            onSelect: { selectedItemId = item.id },
                            onPin: { viewModel.pinItem(with: item.id) },
                            onRename: { newName in
                                viewModel.renameItem(with: item.id, newName: newName)
                                editingItemId = nil
                            },
                            onStartEditing: {
                                editingItemId = item.id
                                editingName = item.customName ?? ""
                            },
                            onCancelEditing: {
                                editingItemId = nil
                            }
                        )
                        .onHover { isHovered in
                            hoveredItemId = isHovered ? item.id : nil
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    let isHovered: Bool
    let isEditing: Bool
    @Binding var editingName: String
    let onSelect: () -> Void
    let onPin: () -> Void
    let onRename: (String) -> Void
    let onStartEditing: () -> Void
    let onCancelEditing: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail/Icon
            if item.type == "Image", let imageData = item.data, let image = NSImage(data: imageData) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            } else {
                Image(systemName: iconFor(type: item.type))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(colorFor(type: item.type))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Enter name", text: $editingName, onCommit: {
                        onRename(editingName)
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .medium))
                } else {
                    Text(item.displayName)
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .medium))
                }
                
                HStack(spacing: 6) {
                    Text(item.type)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(colorFor(type: item.type).opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(timeAgoString(from: item.date))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            if isHovered || isSelected {
                HStack(spacing: 8) {
                    if isEditing {
                        Button(action: { onRename(editingName) }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onCancelEditing) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: onStartEditing) {
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onPin) {
                            Image(systemName: item.isPinned ? "pin.fill" : "pin")
                                .foregroundColor(item.isPinned ? .blue : .secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : 
                      isHovered ? Color.secondary.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
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
