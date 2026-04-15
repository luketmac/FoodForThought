import Foundation
import Observation
import SwiftData

@Observable
class FavoritesViewModel {
    var favoriteRecipes: [RecipeDTO] = []
    var isLoading: Bool = false
    
    private let networkService = MealDBNetworkService()
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadFavoritesFromDatabase()
    }
    
    // MARK: - Database Operations
    
    /// Loads favorites from SwiftData database
    private func loadFavoritesFromDatabase() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<FavoriteRecipe>()
            let savedRecipes = try modelContext.fetch(descriptor)
            
            // Convert FavoriteRecipe objects to RecipeDTO
            favoriteRecipes = savedRecipes.map { saved in
                RecipeDTO(
                    idMeal: saved.id,
                    strMeal: saved.name,
                    strCategory: saved.category,
                    strInstructions: saved.instructions,
                    strMealThumb: saved.imageURL
                )
            }
        } catch {
            print("Error loading favorites from database: \(error)")
        }
    }
    
    /// Saves a recipe to both memory and database
    func saveToFavorites(recipe: RecipeDTO) {
        // Add to in-memory array
        if !favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal }) {
            favoriteRecipes.append(recipe)
        }
        
        // Save to database
        guard let modelContext = modelContext else { return }
        
        let favoriteRecipe = recipe.toFavoriteRecipe()
        modelContext.insert(favoriteRecipe)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving favorite to database: \(error)")
        }
    }
    
    /// Removes a recipe from both memory and database
    func removeFromFavorites(recipe: RecipeDTO) {
        // Remove from in-memory array
        if let index = favoriteRecipes.firstIndex(where: { $0.idMeal == recipe.idMeal }) {
            favoriteRecipes.remove(at: index)
        }
        
        // Remove from database
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
    
    // MARK: - Export/Import Functionality
    
    /// Exports favorites as JSON data
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
    
    /// Exports favorites to a JSON file and returns the file URL
    func exportFavoritesToFile() -> URL? {
        guard let jsonData = exportFavoritesAsJSON() else { return nil }
        
        let fileName = "RecipeFavorites_\(dateString()).json"
        
        // Try to save to Documents directory first, fall back to temp
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try jsonData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error writing to Documents: \(error)")
            }
        }
        
        // Fallback to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try jsonData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error writing to temp directory: \(error)")
            return nil
        }
    }
    
    /// Imports favorites from JSON data
    func importFavoritesFromJSON(_ data: Data) -> Bool {
        let decoder = JSONDecoder()
        
        do {
            let importedRecipes = try decoder.decode([RecipeDTO].self, from: data)
            
            // Add imported recipes, avoiding duplicates
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
    
    /// Helper to generate a timestamp string for filenames
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}


