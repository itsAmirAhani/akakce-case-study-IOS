import SwiftUI

struct HomeScreen: View {
    @StateObject private var vm = ProductViewModel()
    @State private var path = NavigationPath()

    private let grid: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // First 5 in the horizontal, rest in the grid
    private var featured: [Product] {
        Array(vm.allProducts.prefix(5))
    }
    private var remaining: [Product] {
        Array(vm.allProducts.dropFirst(min(5, vm.allProducts.count)))
    }

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                let hPad: CGFloat = 16
                let interItem: CGFloat = 12
                let tileWidth: CGFloat = (proxy.size.width - (hPad * 2) - interItem) / 2
                let tileHeight: CGFloat = 220

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Featured Products")
                            .font(.title2.bold())
                            .padding(.horizontal, hPad)

                        if !featured.isEmpty {
                            PagerSection(
                                pages: makePairs(from: featured),
                                tileWidth: tileWidth,
                                tileHeight: tileHeight,
                                onTap: { path.append($0.id) }
                            )
                            .padding(.horizontal, hPad)
                            .padding(.bottom, 4)
                        }

                        Text("All Products")
                            .font(.title2.bold())
                            .padding(.horizontal, hPad)

                        LazyVGrid(columns: grid, spacing: interItem) {
                            ForEach(remaining, id: \.id) { p in
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
            .overlay { if vm.isLoading { ProgressView().scaleEffect(1.2) } }
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

// Split into pairs of 2 (last can be single)
private func makePairs(from products: [Product]) -> [[Product]] {
    var result: [[Product]] = []
    var i = 0
    while i < products.count {
        let end = min(i + 2, products.count)
        result.append(Array(products[i..<end]))
        i += 2
    }
    return result
}

// MARK: - Pager (dots never overlap cards)
private struct PagerSection: View {
    let pages: [[Product]]          // pairs of 2 (last may be single)
    let tileWidth: CGFloat
    let tileHeight: CGFloat
    let onTap: (Product) -> Void

    var body: some View {
        let interItem: CGFloat = 12
        let dotsHeight: CGFloat = 24        // space for the UIPageControl
        let gutterAboveDots: CGFloat = 12   // breathing room above the dots
        let rowHeight = tileHeight - gutterAboveDots

        TabView {
            ForEach(Array(pages.enumerated()), id: \.0) { _, pair in
                // The row with two cards is slightly shorter than tileHeight
                // so there’s a clean gap before the dots overlay.
                HStack(spacing: interItem) {
                    if let left = pair.first {
                        HorizontalProduct(
                            product: left,
                            cardWidth: tileWidth,
                            onTap: onTap
                        )
                        .frame(width: tileWidth, height: rowHeight, alignment: .top)
                    }

                    if pair.count > 1 {
                        HorizontalProduct(
                            product: pair[1],
                            cardWidth: tileWidth,
                            onTap: onTap
                        )
                        .frame(width: tileWidth, height: rowHeight, alignment: .top)
                    } else {
                        // keep layout left-aligned for a single card
                        Color.clear
                            .frame(width: tileWidth, height: rowHeight)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.bottom, gutterAboveDots) // <-- gap *above* dots
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .automatic))
        .frame(height: rowHeight + dotsHeight) // <-- total height includes dots lane
    }
}
