import Foundation
import Observation

@Observable
class DiscoverViewModel {
    var discoverRecipes: [RecipeDTO] = []
    var favoriteRecipes: [RecipeDTO] = []
    var isLoading: Bool = false
    
    
    private let networkService = MealDBNetworkService()
    
    // Fetches 6 random recipes for the discover grid
    func loadInitialRecipes() async {
        isLoading = true
        discoverRecipes.removeAll()
        
        // TheMealDB only returns 1 random recipe at a time, so we loop it
        for _ in 1...6 {
            if let recipe = try? await networkService.fetchRandomRecipe() {
                discoverRecipes.append(recipe)
            }
        }
        
        isLoading = false
    }
    
    func saveToFavorites(recipe: RecipeDTO) {
        favoriteRecipes.append(recipe)
    }
    
    func removeFromFavorites(recipe: RecipeDTO) {
        if let index = favoriteRecipes.firstIndex(where: { $0.idMeal == recipe.idMeal }) {
            favoriteRecipes.remove(at: index)
        }
    }
}
