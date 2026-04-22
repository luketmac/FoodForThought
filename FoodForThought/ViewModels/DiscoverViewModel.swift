import Foundation
import Observation

/// A view model for managing the discover recipes functionality.
@Observable
class DiscoverViewModel {
    /// The list of discovered recipes.
    var discoverRecipes: [RecipeDTO] = []
    /// Indicates whether the view model is currently loading recipes.
    var isLoading: Bool = false
    
    
    /// The network service for fetching recipes.
    private let networkService = MealDBNetworkService()
    
    /// Loads initial recipes for the discover grid by fetching random recipes.
    func loadInitialRecipes() async {
        isLoading = true
        discoverRecipes.removeAll()
        
        var seenIds = Set<String>()
        var recipesToLoad = 6
        var attempts = 0
        let maxAttempts = 20
        
        while recipesToLoad > 0 && attempts < maxAttempts {
            if let recipe = try? await networkService.fetchRandomRecipe() {
                if !seenIds.contains(recipe.idMeal) {
                    seenIds.insert(recipe.idMeal)
                    discoverRecipes.append(recipe)
                    recipesToLoad -= 1
                }
            }
            attempts += 1
        }
        
        isLoading = false
    }
}