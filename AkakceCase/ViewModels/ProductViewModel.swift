import Foundation

@MainActor
final class ProductViewModel: ObservableObject {
    // Injected dependency (default is a real client)
    private let api: ApiClient

    @Published var allProducts: [Product] = []
    /// Horizontal carousel pages: each page has up to 2 products
    @Published var horizontalProducts: [[Product]] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(api: ApiClient = ApiClient()) {
        self.api = api
    }

    func fetch() async {
        isLoading = true
        errorMessage = nil
        do {
            async let all = api.fetchAllProducts()
            async let limited = api.fetchLimitedProducts(limit: 5)

            let (allList, limitedList) = try await (all, limited)
            self.allProducts = allList

            // chunk limitedList (max 5) into pages of 2 (last page can be 1)
            self.horizontalProducts = stride(from: 0, to: limitedList.count, by: 2).map {
                Array(limitedList[$0..<min($0 + 2, limitedList.count)])
            }
        } catch {
            self.errorMessage = "Failed to load products."
        }
        isLoading = false
    }
}
