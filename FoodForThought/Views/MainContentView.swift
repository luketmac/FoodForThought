import SwiftUI
import SwiftData

struct MainContentView: View {
    // Gives us access to the SwiftData database
    @Environment(\.modelContext) private var modelContext
    
    // The view model for the discover page
    @State private var discoverVM = DiscoverViewModel()
    
    @State private var selectedTab = "Discover"
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                if selectedTab == "Discover" {
                    Text("Discover Page Content Goes Here")
                        .task {
                            // Load recipes when the app opens
                            if discoverVM.discoverRecipes.isEmpty {
                                await discoverVM.loadInitialRecipes()
                            }
                        }
                } else {
                    Text("Favorites Page Content Goes Here")
                }
            }
            .navigationTitle(selectedTab == "Discover" ? "Discover Something Tasty" : "Your Favorites")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Picker("Tabs", selection: $selectedTab) {
                        Text("Discover").tag("Discover")
                        Text("Favorites").tag("Favorites")
                    }
                    .pickerStyle(.segmented)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    TextField("Discover More...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                }
            }
        }
    }
}
