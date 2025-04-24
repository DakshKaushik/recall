//
//  clipboardViewModel.swift
//  Recall
//
//  Created by Daksh Kaushik on 19/04/25.
//
import SwiftUI
import AppKit

struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    init(title: String, value: String, icon: String, color: Color = .accentColor) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ?
                      Color(NSColor.controlBackgroundColor).opacity(0.2) :
                      Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05),
                       radius: 8, x: 0, y: 4)
        )
    }
}
