import SwiftUI
import SwiftData

/// The main entry point of the FoodForThought application.
@main
struct FoodForThoughtApp: App {
    /// The body of the app, defining the main window group and model container.
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
        .modelContainer(for: FavoriteRecipe.self) 
    }
}