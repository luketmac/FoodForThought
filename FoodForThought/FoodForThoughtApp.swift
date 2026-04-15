import SwiftUI
import SwiftData

@main
struct FoodForThoughtApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
        .modelContainer(for: FavoriteRecipe.self) 
    }
}
