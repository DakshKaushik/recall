//
//  clipboardViewModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 19/04/25.
//
import SwiftUI
import AppKit

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
