import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ClipboardViewModel()
    @State private var selectedItem: ClipboardItem?
    init(viewModel: ClipboardViewModel = ClipboardViewModel()) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }
    
    var body: some View {
        NavigationSplitView {
            // Left pane (sidebar) with list of clipboard items
            List(viewModel.clipboardItems, selection: $selectedItem) { item in
                VStack(alignment: .leading) {
                    // Show the first part of the content
                    Text(item.content.prefix(30))
                        .lineLimit(1)
                    // Show the type as a subtitle
                    Text(item.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 250)
            .navigationTitle("Clipboard History")
        } detail: {
            // Detail view showing the selected item
            if let selectedItem = selectedItem {
                VStack(alignment: .leading, spacing: 16) {
                    Text(selectedItem.content)
                        .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Type:")
                            Text(selectedItem.type).bold()
                        }
                        HStack {
                            Text("Date:")
                            Text(selectedItem.date, style: .date).bold()
                        }
                        HStack {
                            Text("Characters:")
                            Text("\(selectedItem.characterCount)").bold()
                        }
                        HStack {
                            Text("Words:")
                            Text("\(selectedItem.wordCount)").bold()
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Clipboard Details")
            } else {
                Text("Select an item from the list")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Clipboard Details")
            }
        }
    }
}
#Preview {
    let mockViewModel = ClipboardViewModel()
    // Add some sample items
    mockViewModel.clipboardItems = [
        ClipboardItem(content: "Sample clipboard text 1", date: Date(), type: "Text"),
        ClipboardItem(content: "Another clipboard item with more content", date: Date().addingTimeInterval(-3600), type: "Text (Formatted)")
    ]
    
    return ContentView(viewModel: mockViewModel)
}

