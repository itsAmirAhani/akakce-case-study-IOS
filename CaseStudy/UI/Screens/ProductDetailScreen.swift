import SwiftUI

struct ProductDetailScreen: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: product.image)) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFit()
                        default:
                            Rectangle()
                                .fill(.gray.opacity(0.1))
                                .overlay(ProgressView())
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .background(.ultraThinMaterial)

                    // Back button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(10)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text("⭐️ \(String(format: "%.1f", product.rating.rate))")
                        Text("(\(product.rating.count) reviews)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)

                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.title2.bold())
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)

                Divider().padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(product.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 20)
            }
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden(true)
    }
}
