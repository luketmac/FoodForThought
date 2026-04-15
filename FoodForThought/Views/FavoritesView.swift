import SwiftUI
import UniformTypeIdentifiers

struct FavoritesView: View {
    // We pass the ViewModel in from the main window
    var viewModel: FavoritesViewModel
    
    // Defines a grid that auto-adjusts columns based on window size
    let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)
    ]
    
    @State private var showingFilePicker = false
    @State private var showingFileExporter = false
    @State private var exportData: Data?
    @State private var importMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.favoriteRecipes.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Start favoriting recipes from the Discover tab")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.favoriteRecipes) { recipe in
                            RecipeCardView(recipe: recipe, isFavorited: true) {
                                viewModel.removeFromFavorites(recipe: recipe)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Favorites")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: exportFavorites) {
                            Label("Export as JSON", systemImage: "arrow.up.doc")
                        }
                        .disabled(viewModel.favoriteRecipes.isEmpty)
                        
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            Label("Import from JSON", systemImage: "arrow.down.doc")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json],
                onCompletion: handleFileImport
            )
            .fileExporter(
                isPresented: $showingFileExporter,
                document: exportData.map { JSONDocument(data: $0) } ?? JSONDocument(data: Data()),
                contentType: .json,
                defaultFilename: "RecipeFavorites_\(dateString()).json",
                onCompletion: handleFileExport
            )
            .alert("Import Favorites", isPresented: Binding(
                get: { !importMessage.isEmpty },
                set: { if !$0 { importMessage = "" } }
            )) {
                Button("OK") {
                    importMessage = ""
                }
            } message: {
                Text(importMessage)
            }
        }
    }
    
    private func exportFavorites() {
        if let jsonData = viewModel.exportFavoritesAsJSON() {
            exportData = jsonData
            showingFileExporter = true
        }
    }
    
    private func handleFileImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            // Start accessing the security-scoped resource
            let fileAccessGranted = url.startAccessingSecurityScopedResource()
            defer {
                if fileAccessGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                let data = try Data(contentsOf: url)
                if viewModel.importFavoritesFromJSON(data) {
                    importMessage = "✓ Favorites imported successfully!"
                } else {
                    importMessage = "✗ Failed to import. Invalid JSON format."
                }
            } catch {
                importMessage = "✗ Error reading file: \(error.localizedDescription)"
            }
        case .failure(let error):
            importMessage = "✗ Error: \(error.localizedDescription)"
        }
    }
    
    private func handleFileExport(result: Result<URL, Error>) {
        switch result {
        case .success(_):
            importMessage = "✓ File saved successfully!"
        case .failure(let error):
            importMessage = "✗ Error saving file: \(error.localizedDescription)"
        }
    }
    
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}

