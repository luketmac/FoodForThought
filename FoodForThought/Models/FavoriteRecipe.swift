import Foundation
import SwiftData

/// A model representing a favorite recipe stored in the SwiftData database.
@Model
class FavoriteRecipe {
    /// The unique identifier of the recipe.
    @Attribute(.unique) var id: String
    /// The name of the recipe.
    var name: String
    /// The category of the recipe.
    var category: String
    /// The area or cuisine of the recipe.
    var area: String
    /// The instructions for preparing the recipe.
    var instructions: String
    /// The URL string for the recipe's image.
    var imageURL: String
    /// The URL string for the recipe's YouTube video.
    var youtubeURL: String
    /// The list of saved ingredients as strings.
    var savedIngredients: [String]
    
    /// Initializes a new FavoriteRecipe instance.
    /// - Parameters:
    ///   - id: The unique identifier.
    ///   - name: The name of the recipe.
    ///   - category: The category.
    ///   - area: The area.
    ///   - instructions: The instructions.
    ///   - imageURL: The image URL.
    ///   - youtubeURL: The YouTube URL.
    ///   - savedIngredients: The ingredients.
    init(id: String, name: String, category: String, area: String, instructions: String, imageURL: String, youtubeURL: String, savedIngredients: [String]) {
        self.id = id
        self.name = name
        self.category = category
        self.area = area
        self.instructions = instructions
        self.imageURL = imageURL
        self.youtubeURL = youtubeURL
        self.savedIngredients = savedIngredients
    }
}

/// A struct representing an ingredient with its measure.
struct RecipeIngredient: Codable, Hashable {
    /// The name of the ingredient.
    let ingredient: String
    /// The measure of the ingredient.
    let measure: String
}

/// A struct representing the response from the MealDB API containing a list of meals.
struct MealResponse: Codable {
    /// The list of meals in the response.
    let meals: [RecipeDTO]?
}

/// A struct representing a recipe data transfer object from the MealDB API.
struct RecipeDTO: Codable, Identifiable {
    /// The unique identifier of the meal.
    var idMeal: String
    /// The name of the meal.
    var strMeal: String
    /// The category of the meal.
    var strCategory: String?
    /// The area of the meal.
    var strArea: String?
    /// The instructions for the meal.
    var strInstructions: String?
    /// The thumbnail image URL.
    var strMealThumb: String?
    /// The YouTube video URL.
    var strYoutube: String?
    
    var strIngredient1: String? = nil
    var strMeasure1: String? = nil
    var strIngredient2: String? = nil
    var strMeasure2: String? = nil
    var strIngredient3: String? = nil
    var strMeasure3: String? = nil
    var strIngredient4: String? = nil
    var strMeasure4: String? = nil
    var strIngredient5: String? = nil
    var strMeasure5: String? = nil
    var strIngredient6: String? = nil
    var strMeasure6: String? = nil
    var strIngredient7: String? = nil
    var strMeasure7: String? = nil
    var strIngredient8: String? = nil
    var strMeasure8: String? = nil
    var strIngredient9: String? = nil
    var strMeasure9: String? = nil
    var strIngredient10: String? = nil
    var strMeasure10: String? = nil
    var strIngredient11: String? = nil
    var strMeasure11: String? = nil
    var strIngredient12: String? = nil
    var strMeasure12: String? = nil
    var strIngredient13: String? = nil
    var strMeasure13: String? = nil
    var strIngredient14: String? = nil
    var strMeasure14: String? = nil
    var strIngredient15: String? = nil
    var strMeasure15: String? = nil
    var strIngredient16: String? = nil
    var strMeasure16: String? = nil
    var strIngredient17: String? = nil
    var strMeasure17: String? = nil
    var strIngredient18: String? = nil
    var strMeasure18: String? = nil
    var strIngredient19: String? = nil
    var strMeasure19: String? = nil
    var strIngredient20: String? = nil
    var strMeasure20: String? = nil
    
    /// The loaded ingredients from the database.
    var loadedDatabaseIngredients: [RecipeIngredient]? = nil
    
    /// The computed identifier.
    var id: String { idMeal }
    
    /// A computed property that returns a list of ingredients with their measures.
    var ingredientsList: [RecipeIngredient] {
        if let dbIngredients = loadedDatabaseIngredients {
            return dbIngredients
        }
        
        var list: [RecipeIngredient] = []
        
        let pairs = [
            (strIngredient1, strMeasure1), (strIngredient2, strMeasure2),
            (strIngredient3, strMeasure3), (strIngredient4, strMeasure4),
            (strIngredient5, strMeasure5), (strIngredient6, strMeasure6),
            (strIngredient7, strMeasure7), (strIngredient8, strMeasure8),
            (strIngredient9, strMeasure9), (strIngredient10, strMeasure10),
            (strIngredient11, strMeasure11), (strIngredient12, strMeasure12),
            (strIngredient13, strMeasure13), (strIngredient14, strMeasure14),
            (strIngredient15, strMeasure15), (strIngredient16, strMeasure16),
            (strIngredient17, strMeasure17), (strIngredient18, strMeasure18),
            (strIngredient19, strMeasure19), (strIngredient20, strMeasure20)
        ]
        
        for pair in pairs {
            if let ing = pair.0?.trimmingCharacters(in: .whitespacesAndNewlines), !ing.isEmpty,
               let meas = pair.1?.trimmingCharacters(in: .whitespacesAndNewlines) {
                list.append(RecipeIngredient(ingredient: ing.capitalized, measure: meas))
            }
        }
        return list
    }
    
    /// Converts the RecipeDTO to a FavoriteRecipe for storage in the database.
    func toFavoriteRecipe() -> FavoriteRecipe {
        let stringArray = ingredientsList.map { "\($0.measure) | \($0.ingredient)" }
        
        return FavoriteRecipe(
            id: self.idMeal,
            name: self.strMeal,
            category: self.strCategory ?? "Unknown",
            area: self.strArea ?? "Unknown",
            instructions: self.strInstructions ?? "No instructions provided.",
            imageURL: self.strMealThumb ?? "",
            youtubeURL: self.strYoutube ?? "",
            savedIngredients: stringArray
        )
    }
}