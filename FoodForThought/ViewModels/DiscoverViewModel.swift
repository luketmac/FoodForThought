import Foundation
import Observation

@Observable
class DiscoverViewModel {
    var discoverRecipes: [RecipeDTO] = []
    var isLoading: Bool = false
    
    
    private let networkService = MealDBNetworkService()
    
    // Fetches 6 random recipes for the discover grid
    func loadInitialRecipes() async {
        isLoading = true
        discoverRecipes.removeAll()
        
        var seenIds = Set<String>()
        var recipesToLoad = 6
        var attempts = 0
        let maxAttempts = 20 // Prevent infinite loops
        
        // TheMealDB only returns 1 random recipe at a time, so we loop it
        while recipesToLoad > 0 && attempts < maxAttempts {
            if let recipe = try? await networkService.fetchRandomRecipe() {
                // Only add if we haven't seen this recipe before
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
