import SwiftUI
import AppKit

struct SidebarView: View {
    let items: [ClipboardItem]
    @Binding var selectedItemId: UUID?
    @Binding var searchText: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
           
            VisualEffectBlur(material: .underWindowBackground, blendingMode: .behindWindow)
                .overlay(Color.black.opacity(0.4))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search clipboard items...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(10)
                .padding([.horizontal, .top])

                
                List(items, selection: $selectedItemId) { item in
                    HStack(spacing: 16) {
                        Image(systemName: iconFor(type: item.type))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(colorFor(type: item.type))
                            .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.content.prefix(30))
                                .lineLimit(1)
                                .font(.system(size: 14, weight: .medium))

                            HStack {
                                Text(item.type)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 6)
                                    .background(colorFor(type: item.type).opacity(0.1))
                                    .cornerRadius(4)

                                Spacer()

                                Text(timeAgoString(from: item.date))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .tag(item.id)
                }
                .listStyle(.sidebar)
                .background(Color.clear)
            }
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
