import Foundation

@MainActor
final class ProductViewModel: ObservableObject {
    private let api: ProductAPI

    @Published var allProducts: [Product] = []
    @Published var horizontalProducts: [[Product]] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(api: ProductAPI = ApiClient()) {
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
            self.horizontalProducts = stride(from: 0, to: limitedList.count, by: 2).map {
                Array(limitedList[$0..<min($0 + 2, limitedList.count)])
            }
        } catch {
            self.errorMessage = "Failed to load products."
        }
        isLoading = false
    }
}
