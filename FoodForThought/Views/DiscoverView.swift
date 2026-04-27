import SwiftUI

/// A view for displaying the discover recipes in a grid.
struct DiscoverView: View {
    /// The view model for discover functionality.
    var viewModel: DiscoverViewModel
    /// The view model for favorites.
    var favoritesViewModel: FavoritesViewModel
    
    /// The grid layout for the recipes.
    let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)
    ]

    /// The body of the view.
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading deliciousness...")
                    .padding(.top, 50)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.discoverRecipes) { recipe in
                        let isFav = favoritesViewModel.favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal })
                        
                        NavigationLink(destination: RecipeDetailView(recipe: recipe, favoritesViewModel: favoritesViewModel)) {
                            RecipeCardView(recipe: recipe, isFavorited: isFav) {
                                if isFav {
                                    favoritesViewModel.removeFromFavorites(recipe: recipe)
                                } else {
                                    favoritesViewModel.saveToFavorites(recipe: recipe)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}
