import SwiftUI
import SwiftData

/// The main content view of the application, handling tab navigation between discover and favorites.
struct MainContentView: View {
    /// The environment model context for SwiftData.
    @Environment(\.modelContext) private var modelContext
    
    /// The view model for discover functionality.
    @State private var discoverVM = DiscoverViewModel()
    /// The view model for favorites.
    @State private var favoritesVM: FavoritesViewModel?
    
    /// The selected tab.
    @State private var selectedTab = "Discover"
    /// The search text.
    @State private var searchText = ""

    /// The body of the view.
    var body: some View {
        NavigationStack {
            VStack {
                if selectedTab == "Discover" {
                    if let favoritesVM = favoritesVM {
                        DiscoverView(viewModel: discoverVM, favoritesViewModel: favoritesVM)
                            .task {
                                if discoverVM.discoverRecipes.isEmpty {
                                    await discoverVM.loadInitialRecipes()
                                }
                            }
                    }
                }
                if selectedTab == "Favorites" {
                    if let favoritesVM = favoritesVM {
                        FavoritesView(viewModel: favoritesVM)
                    }
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
                        .padding(5)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task {
                            await discoverVM.loadInitialRecipes()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .padding()
                    }
                }
            }
            .onAppear {
                if favoritesVM == nil {
                    favoritesVM = FavoritesViewModel(modelContext: modelContext)
                }
            }
        }
    }
}