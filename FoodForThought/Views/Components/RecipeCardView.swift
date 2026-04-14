import SwiftUI

struct RecipeCardView: View {
    let recipe: RecipeDTO
    let onSave: () -> Void // Action to run when the star is clicked
    
    // We assume it's not saved for this simple visual, 
    // but you can pass real saved state here later.
    @State private var isSaved: Bool = false 

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 1. The Background Image
            if let imageUrlString = recipe.strMealThumb, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // 2. A dark gradient to make the white text readable
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // 3. The Title Text
            Text(recipe.strMeal)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            
            // 4. The Favorite Star Button
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
            .buttonStyle(.plain) // Prevents the whole card from acting like a button on Mac
            .padding(8)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}