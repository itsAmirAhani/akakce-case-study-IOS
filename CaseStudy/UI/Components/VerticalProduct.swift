import SwiftUI

struct VerticalProduct: View {
    let product: Product
    let onTap: (Product) -> Void

    private let imageHeight: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // IMAGE (centered)
            ZStack {
                AsyncImage(url: URL(string: product.image)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.1))
                            .overlay(ProgressView())
                    }
                }
                .frame(maxWidth: .infinity)   // center horizontally
            }
            .frame(height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // TEXTS (left-aligned)
            Text(product.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                .lineLimit(2)

            Text(formatPrice(product.price))
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack(spacing: 4) {
                Text("⭐️ \(String(format: "%.1f", product.rating.rate))")
                Text("(\(product.rating.count))")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)

            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap(product) }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
    }
}
