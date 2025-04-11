//
//  RecallApp.swift
//  Recall
//
//  Created by Daksh Kaushik on 09/04/25.
//

import SwiftUI

@main
struct RecallApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(clipboardService: MacClipboardService())
        }
    }
}
