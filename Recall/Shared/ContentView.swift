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
        NavigationSplitView{
            List{
                Text("check1")
                Text("check2")
                Text("check3")
            }
            .frame(minWidth: 200)
            .navigationTitle("Histoy")
            
        }detail:{
            
        }
    }
}
class MockClipboardService: ClipboardService {
    func getClipboardText() -> String? {
        return "Text"
    }
}

#Preview {
    ContentView(clipboardService:MockClipboardService())
}
