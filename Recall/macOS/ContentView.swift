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
            return viewModel.clipboardItems.filter { item in
                if item.type == "Image" {
                    return "Image".localizedCaseInsensitiveContains(searchText) || item.customName?.localizedCaseInsensitiveContains(searchText) ?? false
                }
                else{
                    return item.content?.localizedCaseInsensitiveContains(searchText) ?? false || item.customName?.localizedCaseInsensitiveContains(searchText) ?? false
                }
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(
                items: filteredItems,
                selectedItemId: $selectedItemId,
                searchText: $searchText,
                viewModel: viewModel
            )
            .frame(minWidth: 280)
            .background(
                VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
                    .opacity(0.8)
            )
        } detail: {
            DetailView(
                selectedItem: selectedItemId != nil ? viewModel.clipboardItems.first(where: { $0.id == selectedItemId }) : nil,
                viewModel: viewModel,
                selectedItemId: $selectedItemId
            )
            .background(
                VisualEffectBlur(material: .contentBackground, blendingMode: .behindWindow)
                    .opacity(0.8)
            )
        }
        .navigationSplitViewStyle(.balanced)
    }
}
