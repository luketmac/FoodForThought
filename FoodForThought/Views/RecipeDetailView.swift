import SwiftUI

/// A view for displaying detailed information about a recipe.
struct RecipeDetailView: View {
    /// The recipe to display.
    let recipe: RecipeDTO
    /// The view model for managing favorites.
    var favoritesViewModel: FavoritesViewModel
    
    /// The selected tab for ingredients or instructions.
    @State private var selectedTab = "Ingredients"
    
    /// A computed property indicating if the recipe is favorited.
    var isFavorited: Bool {
        favoritesViewModel.favoriteRecipes.contains(where: { $0.idMeal == recipe.idMeal })
    }
    
    /// A computed property that parses and cleans the recipe instructions.
    private var parsedInstructions: [String] {
        guard let instructions = recipe.strInstructions else { return [] }
        
        let rawLines = instructions
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 2 }
            .map { step -> String in
                let pattern = "^(?i)(step\\s*\\d*|\\d+)[\\.\\:\\-\\) ]?\\s*"
                var cleanStep = step.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                
                while let first = cleanStep.first, first.isPunctuation || first.isWhitespace {
                    cleanStep.removeFirst()
                }
                return cleanStep.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
        
        var combinedSteps: [String] = []
        var i = 0
        
        while i < rawLines.count {
            let currentLine = rawLines[i]
            
            let isHeader = currentLine.hasSuffix(":") || (currentLine.count < 40 && !currentLine.hasSuffix(".") && !currentLine.hasSuffix("!") && !currentLine.hasSuffix("?"))
            
            if isHeader && (i + 1 < rawLines.count) {
                let nextLine = rawLines[i + 1]
                
                let separator = currentLine.hasSuffix(":") ? " " : ": "
                
                combinedSteps.append("\(currentLine)\(separator)\(nextLine)")
                i += 2
            } else {
                combinedSteps.append(currentLine)
                i += 1
            }
        }
        
        return combinedSteps
    }
    
    /// The body of the view.
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 40) {
                VStack(spacing: 24) {
                    if let imageUrlString = recipe.strMealThumb, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 320, height: 320)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                            } else {
                                ProgressView()
                                    .frame(width: 320, height: 320)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    }
                    
                    if let ytLink = recipe.strYoutube, let url = URL(string: ytLink) {
                        Link(destination: url) {
                            Label("Watch Tutorial", systemImage: "play.tv.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.red)
                                .clipShape(Capsule())
                                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Label(recipe.strCategory ?? "Unknown", systemImage: "folder.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                        
                        if let area = recipe.strArea {
                            Label(area, systemImage: "globe.americas.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Picker("View Selection", selection: $selectedTab) {
                        Text("Ingredients").tag("Ingredients")
                        Text("Instructions").tag("Instructions")
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    
                    if selectedTab == "Ingredients" {
                        VStack(spacing: 0) {
                            if recipe.ingredientsList.isEmpty {
                                Text("No ingredients listed.")
                                    .foregroundColor(.secondary)
                                    .padding(20)
                            } else {
                                let ingredients = recipe.ingredientsList
                                ForEach(ingredients.indices, id: \.self) { index in
                                    let item = ingredients[index]
                                    HStack {
                                        Text(item.ingredient)
                                            .font(.system(size: 14, weight: .semibold))
                                        Spacer()
                                        Text(item.measure)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(index % 2 == 0 ? Color.gray.opacity(0.05) : Color.clear)
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        Spacer(minLength: 0)
                        
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            if parsedInstructions.isEmpty {
                                Text("No instructions provided.")
                                    .foregroundColor(.secondary)
                                    .padding(20)
                            } else {
                                ForEach(Array(parsedInstructions.enumerated()), id: \.offset) { index, step in
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(alignment: .top, spacing: 16) {
                                            Text("\(index + 1)")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 24, height: 24)
                                                .background(Color.accentColor)
                                                .clipShape(Circle())
                                                .padding(.top, 2)
                                            
                                            Text(step)
                                                .font(.system(size: 15, weight: .regular))
                                                .lineSpacing(6)
                                                .foregroundColor(.primary.opacity(0.85))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        
                                        if index < parsedInstructions.count - 1 {
                                            Divider()
                                                .padding(.leading, 60)
                                        }
                                    }
                                }
                            }
                        }
                        .background(Color.gray.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(40)
        }
        .navigationTitle(recipe.strMeal)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: "Check out this recipe for \(recipe.strMeal):\n\n\(recipe.strInstructions ?? "")") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(isFavorited ? .yellow : .secondary)
                }
            }
        }
    }
    
    /// Toggles the favorite status of the recipe.
    private func toggleFavorite() {
        if isFavorited {
            favoritesViewModel.removeFromFavorites(recipe: recipe)
        } else {
            favoritesViewModel.saveToFavorites(recipe: recipe)
        }
    }
}
