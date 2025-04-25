import SwiftUI
import AppKit

struct DetailView: View {
    let selectedItem: ClipboardItem?
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ClipboardViewModel
    @Binding var selectedItemId: UUID?

    var body: some View {
        ZStack {
            
            VisualEffectBlur(material: .underWindowBackground, blendingMode: .behindWindow)
                .overlay(Color.black.opacity(0.4))
                .ignoresSafeArea()

         
            if let item = selectedItem {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                      
                        HStack {
                            Image(systemName: iconFor(type: item.type))
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(colorFor(type: item.type))
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.type)
                                    .font(.headline)

                                Text(item.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 12) {
                                Button(action: {
                                    viewModel.copyItem(with: item.id)
                                }) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                .buttonStyle(.borderedProminent)

                                Button(action: {
                                    viewModel.removeItem(with: item.id)
                                    selectedItemId = nil
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }
                        }
                        .padding(16)

                       
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Content")
                                    .font(.headline)
                                Spacer()
                                Text("\(item.characterCount) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            ScrollView(.horizontal) {
                                Text(item.content)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(12)
                                    .textSelection(.enabled)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }

                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Stats")
                                .font(.headline)

                            HStack {
                                StatBadge(title: "Characters", value: "\(item.characterCount)", icon: "character.textbox")
                                StatBadge(title: "Words", value: "\(item.wordCount)", icon: "text.word.spacing")
                                StatBadge(title: "Lines", value: "\(item.content.components(separatedBy: .newlines).count)", icon: "list.bullet")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(20)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Details")

                
            } else {
                
                VStack(spacing: 20) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.8))
                        .padding(24)
                        .background(Circle().fill(Color.secondary.opacity(0.1)))

                    Text("Select an item from the list")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.primary)

                    Text("Clipboard details will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("")
                
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
}
