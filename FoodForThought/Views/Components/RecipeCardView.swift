import SwiftUI

struct RecipeCardView: View {
    let recipe: RecipeDTO
    let onSave: () -> Void
    
    @State private var isSaved: Bool = false

    var body: some View {
        Group {
            // The Background Image
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
                            .aspectRatio(contentMode: .fill)
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
        
        // Dark Overlay
        .overlay(Color.black.opacity(0.3))
        
        // Centered Title Text
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
        
        // Pinned Favorite Button
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                isSaved.toggle()
                onSave()
            }) {
                Image(systemName: isSaved ? "star.circle.fill" : "star.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSaved ? .yellow : .white)
                    .background(Circle().fill(.black.opacity(0.5)))
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        
        // Applies the rounded corners and shadow to the final composed shape
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}
