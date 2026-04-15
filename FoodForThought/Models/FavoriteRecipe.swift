import Foundation
import SwiftData

@Model
class SavedRecipe {
    @Attribute(.unique) var id: String // Ensures we don't save duplicates
    var name: String
    var category: String
    var instructions: String
    var imageURL: String
    
    init(id: String, name: String, category: String, instructions: String, imageURL: String) {
        self.id = id
        self.name = name
        self.category = category
        self.instructions = instructions
        self.imageURL = imageURL
    }
}

struct MealResponse: Codable {
    let meals: [RecipeDTO]?
}

struct RecipeDTO: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strInstructions: String?
    let strMealThumb: String?
    
    var id: String { idMeal }
    
    // A helper to easily convert network data into a saved database object
    func toSavedRecipe() -> SavedRecipe {
        SavedRecipe(
            id: self.idMeal,
            name: self.strMeal,
            category: self.strCategory ?? "Unknown",
            instructions: self.strInstructions ?? "No instructions provided.",
            imageURL: self.strMealThumb ?? ""
        )
    }
}
