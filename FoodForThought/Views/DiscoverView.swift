import SwiftUI

struct DiscoverView: View {
    // We pass the ViewModel in from the main window
    var viewModel: DiscoverViewModel
    var favoritesViewModel: FavoritesViewModel
    
    // Defines a grid that auto-adjusts columns based on window size
    let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading deliciousness...")
                    .padding(.top, 50)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.discoverRecipes) { recipe in
                        RecipeCardView(recipe: recipe, isFavorited: favoritesViewModel.favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal })) {
                            if !favoritesViewModel.favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal }) {
                                favoritesViewModel.saveToFavorites(recipe: recipe)
                            } else {
                                favoritesViewModel.removeFromFavorites(recipe: recipe)
                            }
                            print("Clicked save for \(recipe.strMeal)")
                            print("Current favorites: \(favoritesViewModel.favoriteRecipes.map { $0.strMeal })")
                        }
                    }
                }
                .padding()
            }
        }
    }
}
