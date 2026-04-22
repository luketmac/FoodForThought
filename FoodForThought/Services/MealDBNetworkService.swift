import Foundation

/// A service class for interacting with the MealDB API.
class MealDBNetworkService {
    /// The URL for fetching a random recipe from TheMealDB.
    private let randomURL = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php")!
    
    /// Fetches a random recipe from the MealDB API.
    /// - Returns: A RecipeDTO if successful, nil otherwise.
    /// - Throws: An error if the network request fails.
    func fetchRandomRecipe() async throws -> RecipeDTO? {
        let (data, response) = try await URLSession.shared.data(from: randomURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(MealResponse.self, from: data)
        return result.meals?.first
    }
}