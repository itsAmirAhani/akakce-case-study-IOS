import Foundation

// Simple protocol so we can mock in tests
protocol ProductAPI {
    func fetchAllProducts() async throws -> [Product]
    func fetchLimitedProducts(limit: Int) async throws -> [Product]
}
