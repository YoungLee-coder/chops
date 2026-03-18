import SwiftUI

extension Notification.Name {
    static let customScanPathsChanged = Notification.Name("customScanPathsChanged")
}

struct SettingsView: View {
    @State private var customPaths: [String] = []
    @State private var defaultTool: ToolSource = .claude

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            scanSettings
                .tabItem {
                    Label("Scan Directories", systemImage: "folder.badge.gearshape")
                }
        }
        .frame(width: 480, height: 320)
        .onAppear {
            loadCustomPaths()
        }
    }

    private var generalSettings: some View {
        Form {
            Picker("Default tool for new skills", selection: $defaultTool) {
                ForEach(ToolSource.allCases) { tool in
                    Text(tool.displayName).tag(tool)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var scanSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Scan Directories")
                .font(.headline)

            Text("Add a parent directory (e.g. ~/Development) and Chops will scan each project inside it for tool-specific skills.")
                .font(.caption)
                .foregroundStyle(.secondary)

            List {
                ForEach(customPaths, id: \.self) { path in
                    HStack {
                        Image(systemName: "folder")
                        Text(path)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button {
                            customPaths.removeAll { $0 == path }
                            saveCustomPaths()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(minHeight: 120)

            HStack {
                Spacer()
                Button("Add Directory...") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK, let url = panel.url {
                        let path = url.path
                        if !customPaths.contains(path) {
                            customPaths.append(path)
                            saveCustomPaths()
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func loadCustomPaths() {
        customPaths = UserDefaults.standard.stringArray(forKey: "customScanPaths") ?? []
    }

    private func saveCustomPaths() {
        UserDefaults.standard.set(customPaths, forKey: "customScanPaths")
        NotificationCenter.default.post(name: .customScanPathsChanged, object: nil)
    }
}
