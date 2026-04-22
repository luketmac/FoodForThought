import Foundation
import Observation
import SwiftData

/// A view model for managing favorite recipes, including database operations and export/import functionality.
@Observable
class FavoritesViewModel {
    /// The list of favorite recipes.
    var favoriteRecipes: [RecipeDTO] = []
    /// Indicates whether the view model is currently loading.
    var isLoading: Bool = false
    
    /// The network service for fetching recipes.
    private let networkService = MealDBNetworkService()
    /// The model context for database operations.
    private var modelContext: ModelContext?
    
    /// Initializes the view model with an optional model context.
    /// - Parameter modelContext: The SwiftData model context.
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadFavoritesFromDatabase()
    }
    
    /// Loads favorites from the SwiftData database.
    private func loadFavoritesFromDatabase() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<FavoriteRecipe>()
            let savedRecipes = try modelContext.fetch(descriptor)
            
            favoriteRecipes = savedRecipes.map { saved in
                let parsedIngredients = saved.savedIngredients.map { item -> RecipeIngredient in
                    let components = item.components(separatedBy: " | ")
                    if components.count == 2 {
                        return RecipeIngredient(ingredient: components[1], measure: components[0])
                    }
                    return RecipeIngredient(ingredient: item, measure: "")
                }
                
                return RecipeDTO(
                    idMeal: saved.id,
                    strMeal: saved.name,
                    strCategory: saved.category,
                    strArea: saved.area,
                    strInstructions: saved.instructions,
                    strMealThumb: saved.imageURL,
                    strYoutube: saved.youtubeURL,
                    loadedDatabaseIngredients: parsedIngredients
                )
            }
        } catch {
            print("Error loading favorites from database: \(error)")
        }
    }
    
    /// Saves a recipe to both memory and database.
    /// - Parameter recipe: The recipe to save.
    func saveToFavorites(recipe: RecipeDTO) {
        if !favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal }) {
            favoriteRecipes.append(recipe)
        }
        
        guard let modelContext = modelContext else { return }
        
        let favoriteRecipe = recipe.toFavoriteRecipe()
        modelContext.insert(favoriteRecipe)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving favorite to database: \(error)")
        }
    }
    
    /// Removes a recipe from both memory and database.
    /// - Parameter recipe: The recipe to remove.
    func removeFromFavorites(recipe: RecipeDTO) {
        if let index = favoriteRecipes.firstIndex(where: { $0.idMeal == recipe.idMeal }) {
            favoriteRecipes.remove(at: index)
        }
        
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<FavoriteRecipe>(predicate: #Predicate { $0.id == recipe.idMeal })
            let recipes = try modelContext.fetch(descriptor)
            
            for recipe in recipes {
                modelContext.delete(recipe)
            }
            
            try modelContext.save()
        } catch {
            print("Error deleting favorite from database: \(error)")
        }
    }
    
    /// Exports favorites as JSON data.
    /// - Returns: The JSON data if successful, nil otherwise.
    func exportFavoritesAsJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(favoriteRecipes)
            return data
        } catch {
            print("Error encoding favorites to JSON: \(error)")
            return nil
        }
    }
    
    /// Exports favorites to a JSON file and returns the file URL.
    /// - Returns: The URL of the exported file if successful, nil otherwise.
    func exportFavoritesToFile() -> URL? {
        guard let jsonData = exportFavoritesAsJSON() else { return nil }
        
        let fileName = "RecipeFavorites_\(dateString()).json"
        
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try jsonData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error writing to Documents: \(error)")
            }
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try jsonData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error writing to temp directory: \(error)")
            return nil
        }
    }
    
    /// Imports favorites from JSON data.
    /// - Parameter data: The JSON data to import.
    /// - Returns: True if import was successful, false otherwise.
    func importFavoritesFromJSON(_ data: Data) -> Bool {
        let decoder = JSONDecoder()
        
        do {
            let importedRecipes = try decoder.decode([RecipeDTO].self, from: data)
            
            for recipe in importedRecipes {
                if !favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal }) {
                    saveToFavorites(recipe: recipe)
                }
            }
            
            return true
        } catch {
            print("Error decoding JSON: \(error)")
            return false
        }
    }
    
    /// Generates a timestamp string for filenames.
    /// - Returns: A formatted date string.
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}