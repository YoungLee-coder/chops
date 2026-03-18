import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Skill.name) private var allSkills: [Skill]
    @Query(sort: \SkillCollection.sortOrder) private var collections: [SkillCollection]

    private var activeSources: [ToolSource] {
        ToolSource.allCases.filter { tool in
            allSkills.contains { $0.toolSources.contains(tool) }
        }
    }

    private func toolCount(_ tool: ToolSource) -> Int {
        allSkills.filter { $0.toolSources.contains(tool) }.count
    }

    var body: some View {
        @Bindable var appState = appState

        List(selection: $appState.sidebarFilter) {
            Section("Library") {
                Label("All Skills", systemImage: "tray.full")
                    .badge(allSkills.count)
                    .tag(SidebarFilter.all)

                Label("Favorites", systemImage: "star")
                    .badge(allSkills.filter(\.isFavorite).count)
                    .tag(SidebarFilter.favorites)
            }

            Section("Tools") {
                ForEach(activeSources) { tool in
                    Label {
                        Text(tool.displayName)
                    } icon: {
                        ToolIcon(tool: tool)
                    }
                    .badge(toolCount(tool))
                    .tag(SidebarFilter.tool(tool))
                }
            }

            Section("Collections") {
                CollectionListView()
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Chops")
    }
}
