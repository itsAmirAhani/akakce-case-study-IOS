import SwiftUI

struct HomeScreen: View {
    @StateObject private var vm = ProductViewModel()
    @State private var path = NavigationPath()

    private let hPad: CGFloat = 16
    private let interItem: CGFloat = 12

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                let cardWidth = (proxy.size.width - (hPad * 2) - interItem) / 2
                let cardHeight: CGFloat = 220

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Featured Products")
                            .font(.title2.bold())
                            .padding(.horizontal, hPad)

                        if !vm.horizontalProducts.isEmpty {
                            PagerSection(
                                pages: vm.horizontalProducts,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight
                            ) { path.append($0.id) }
                            .padding(.horizontal, hPad)
                            .padding(.bottom, 6)
                        }

                        Text("All Products")
                            .font(.title2.bold())
                            .padding(.horizontal, hPad)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: interItem),
                                GridItem(.flexible(), spacing: interItem)
                            ],
                            spacing: interItem
                        ) {
                            ForEach(vm.allProducts, id: \.id) { p in
                                VerticalProduct(product: p) { path.append($0.id) }
                            }
                        }
                        .padding(.horizontal, hPad)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Akakce")
            .toolbarTitleDisplayMode(.inline)
            .task { await vm.fetch() }
            .overlay { if vm.isLoading { ProgressView().scaleEffect(1.1) } }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { if !$0 { vm.errorMessage = nil } }
                ),
                actions: { Button("OK", role: .cancel) { vm.errorMessage = nil } },
                message: { Text(vm.errorMessage ?? "") }
            )
            .navigationDestination(for: Int.self) { id in
                if let p = vm.allProducts.first(where: { $0.id == id }) {
                    ProductDetailScreen(product: p)
                } else {
                    Text("Product not found").padding()
                }
            }
        }
    }
}

/// Horizontal pager (pages of 2) that uses the SAME card style/size as grid.
private struct PagerSection: View {
    let pages: [[Product]]          // pairs of 2 (last can be single)
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let onTap: (Product) -> Void

    var body: some View {
        TabView {
            ForEach(pages.indices, id: \.self) { i in
                let pair = pages[i]
                HStack(spacing: 12) {
                    if let left = pair.first {
                        HorizontalProduct(product: left, cardWidth: cardWidth, onTap: onTap)
                            .frame(height: cardHeight, alignment: .top)
                    }
                    if pair.count > 1 {
                        HorizontalProduct(product: pair[1], cardWidth: cardWidth, onTap: onTap)
                            .frame(height: cardHeight, alignment: .top)
                    } else {
                        Color.clear.frame(width: cardWidth, height: cardHeight)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: cardHeight + 18)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}
