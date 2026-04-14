//
//  MealDBNetworkService.swift
//  FoodForThought
//
//  Created by Luke Macintosh on 4/14/26.
//


import Foundation

class MealDBNetworkService {
    // TheMealDB random endpoint
    private let randomURL = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php")!
    
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