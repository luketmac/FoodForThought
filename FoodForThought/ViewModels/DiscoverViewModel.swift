import Foundation
import Observation

@Observable
class DiscoverViewModel {
    var discoverRecipes: [RecipeDTO] = []
    var isLoading: Bool = false
    
    private let networkService = MealDBNetworkService()
    
    // Fetches 9 random recipes for the discover grid
    func loadInitialRecipes() async {
        isLoading = true
        discoverRecipes.removeAll()
        
        // TheMealDB only returns 1 random recipe at a time, so we loop it
        for _ in 1...9 {
            if let recipe = try? await networkService.fetchRandomRecipe() {
                discoverRecipes.append(recipe)
            }
        }
        
        isLoading = false
    }
}
