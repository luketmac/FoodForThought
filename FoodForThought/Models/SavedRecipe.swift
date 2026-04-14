import Foundation
import SwiftData

// 1. The SwiftData Database Model (What you save to the Mac)
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

// 2. The Network Model (What comes from the API)
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