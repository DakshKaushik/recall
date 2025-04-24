import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = ClipboardViewModel()
    @State private var selectedItemId: UUID?
    @State private var searchText = ""
    
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
            SidebarView(
                items: filteredItems,
                selectedItemId: $selectedItemId,
                searchText: $searchText
            )
            .frame(minWidth: 280)
            
        } detail: {
            DetailView(
                selectedItem: selectedItemId != nil ? viewModel.clipboardItems.first(where: { $0.id == selectedItemId }) : nil,
               viewModel: viewModel,
                selectedItemId:$selectedItemId
            )
        }
        .navigationSplitViewStyle(.balanced)
        
    }
}

#Preview {
    let mockViewModel = ClipboardViewModel()
    // Add some sample items
    mockViewModel.clipboardItems = [
        ClipboardItem(content: "Sample clipboard text that might be long enough to show line wrapping", date: Date(), type: "Text"),
    ]
    
    return ContentView(viewModel: mockViewModel)
}
