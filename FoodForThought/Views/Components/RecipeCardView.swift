import SwiftUI

/// A view representing a card for a recipe, displaying its image and favorite button.
struct RecipeCardView: View {
    /// The recipe to display.
    let recipe: RecipeDTO
    /// Indicates if the recipe is favorited.
    let isFavorited: Bool
    /// The action to perform when the favorite button is tapped.
    let onSave: () -> Void

    /// The body of the view.
    var body: some View {
        Group {
            if let imageUrlString = recipe.strMealThumb, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.2))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(4/3, contentMode: .fill)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.2))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        
        .overlay(Color.black.opacity(0.3))
        
        .overlay(alignment: .center) {
            Text(recipe.strMeal)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 16)
                .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
        }
        
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                onSave()
            }) {
                Image(systemName: isFavorited ? "star.circle.fill" : "star.circle")
                    .resizable()
                    .frame(width: 24, height: 24, )
                    .foregroundColor(isFavorited ? .yellow : .white)
                    .background(Circle().fill(.black.opacity(0.5)))
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}
