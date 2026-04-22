import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeDTO
    var favoritesViewModel: FavoritesViewModel
    
    // Check if this specific recipe is in our favorites
    var isFavorited: Bool {
        favoritesViewModel.favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal })
    }
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 30) {
                
                // LEFT COLUMN: Media
                VStack(spacing: 20) {
                    if let imageUrlString = recipe.strMealThumb, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                    }
                    
                    // YouTube Button (If the API has a link)
                    if let ytLink = recipe.strYoutube, let url = URL(string: ytLink) {
                        Link(destination: url) {
                            Label("Watch Tutorial on YouTube", systemImage: "play.rectangle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 400)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 400)
                
                // RIGHT COLUMN: Details
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Category: \(recipe.strCategory ?? "Unknown")")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if let area = recipe.strArea {
                            Text("• Area: \(area)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text("Instructions:")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(recipe.strInstructions ?? "No instructions provided.")
                        .font(.body)
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(30)
        }
        // Native macOS Toolbar settings
        .navigationTitle(recipe.strMeal)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // SwiftUI Native Share Button
                ShareLink(item: "Check out this recipe for \(recipe.strMeal):\n\n\(recipe.strInstructions ?? "")") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(isFavorited ? .yellow : .secondary)
                }
            }
        }
    }
    
    private func toggleFavorite() {
        if isFavorited {
            favoritesViewModel.removeFromFavorites(recipe: recipe)
        } else {
            favoritesViewModel.saveToFavorites(recipe: recipe)
        }
    }
}