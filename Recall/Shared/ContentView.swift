//
//  ContentView.swift
//  Recall
//
//  Created by Daksh Kaushik on 09/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ClipboardViewModel
    init(clipboardService:ClipboardService){
        _viewModel=StateObject(wrappedValue: ClipboardViewModel(clipboardService: clipboardService))
    }
    var body:some View{
        VStack(spacing: 20) {
                    Text("Clipboard App")
                        .font(.title)

                    Text(viewModel.clipboardText)
                        .padding()

                    Button("Fetch Clipboard") {
                        viewModel.fetchClipboard()
                    }
                }
                .padding()
    }
}
class MockClipboardService: ClipboardService {
    func getClipboardText() -> String? {
        return "Preview clipboard text"
    }
}

#Preview {
    ContentView(clipboardService:MockClipboardService())
}
