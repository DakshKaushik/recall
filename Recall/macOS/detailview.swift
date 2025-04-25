import SwiftUI
import AppKit

struct DetailView: View {
    let selectedItem: ClipboardItem?
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ClipboardViewModel
    @Binding var selectedItemId: UUID?
    @State private var isEditingName = false
    @State private var editingName = ""

    var body: some View {
        ZStack {
            VisualEffectBlur(material: .underWindowBackground, blendingMode: .behindWindow)
                .overlay(Color.black.opacity(0.4))
                .ignoresSafeArea()

            if let item = selectedItem {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack(spacing: 16) {
                            if item.type == "Image", let imageData = item.data, let image = NSImage(data: imageData) {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: iconFor(type: item.type))
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(colorFor(type: item.type))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                if isEditingName {
                                    TextField("Enter name", text: $editingName, onCommit: {
                                        viewModel.renameItem(with: item.id, newName: editingName)
                                        isEditingName = false
                                    })
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.title3.weight(.medium))
                                } else {
                                    Text(item.displayName)
                                        .font(.title3.weight(.medium))
                                }

                                HStack(spacing: 8) {
                                    Text(item.type)
                                        .font(.system(size: 12, weight: .medium))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(colorFor(type: item.type).opacity(0.1))
                                        .cornerRadius(6)

                                    Text(item.date, style: .date)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            HStack(spacing: 12) {
                                if isEditingName {
                                    Button(action: {
                                        viewModel.renameItem(with: item.id, newName: editingName)
                                        isEditingName = false
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green.opacity(0.2))

                                    Button(action: {
                                        isEditingName = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red.opacity(0.2))
                                } else {
                                    Button(action: {
                                        editingName = item.customName ?? ""
                                        isEditingName = true
                                    }) {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .buttonStyle(.borderedProminent)

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
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)

                        // Content
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Content")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            if item.type == "Image", let imageData = item.data, let image = NSImage(data: imageData) {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(12)
                            } else {
                                ScrollView([.horizontal, .vertical]) {
                                    Text(item.content ?? "")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                                        .background(Color.black.opacity(0.2))
                                        .cornerRadius(12)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)

                        if item.type == "Text" {
                            // Stats
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Stats")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 16) {
                                    StatBadge(title: "Characters", value: "\(item.characterCount)", icon: "character.textbox")
                                    StatBadge(title: "Words", value: "\(item.wordCount)", icon: "text.word.spacing")
                                    StatBadge(title: "Lines", value: "\(item.content?.components(separatedBy: .newlines).count ?? 0)", icon: "list.bullet")
                                }
                            }
                            .padding(20)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    .padding(24)
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
