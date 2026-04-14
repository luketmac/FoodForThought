import SwiftUI
import SwiftData

@main
struct FoodForThoughtApp: App { // Replace 'FoodForThoughtApp' with your actual app name
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
        // This single line creates the local database and makes it available to all views!
        .modelContainer(for: SavedRecipe.self) 
    }
}