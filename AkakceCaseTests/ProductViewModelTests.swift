import XCTest
@testable import AkakceCase

// A tiny mock that conforms to ProductAPI so we can inject it into the VM.
private struct MockAPI: ProductAPI {
    let all: [Product]
    let limited: [Product]
    let shouldThrow: Bool

    func fetchAllProducts() async throws -> [Product] {
        if shouldThrow { throw APIError.badResponse }
        return all
    }

    func fetchLimitedProducts(limit: Int) async throws -> [Product] {
        if shouldThrow { throw APIError.badResponse }
        // Respect the limit just like the real API would.
        return Array(limited.prefix(limit))
    }
}

final class ProductViewModelTests: XCTestCase {

    // Sample data in the SAME label order as your Product struct:
    // id, title, price, description, category, image, rating
    private func sampleProducts(_ n: Int) -> [Product] {
        (1...n).map { i in
            Product(
                id: i,
                title: "P\(i)",
                price: Double(i) * 10,
                description: "desc\(i)",
                category: "cat",
                image: "https://example.com/\(i).png",
                rating: Rating(rate: 4.2, count: 100)
            )
        }
    }

    @MainActor
    func testFetch_success_populatesAllAndHorizontal() async {
        // Given
        let all = sampleProducts(8)
        let limited = sampleProducts(5)        // first 5 become featured
        let vm = ProductViewModel(api: MockAPI(all: all, limited: limited, shouldThrow: false))

        // When
        await vm.fetch()

        // Then
        XCTAssertEqual(vm.allProducts.count, 8)

        // horizontalProducts should be chunked into pairs: [[1,2],[3,4],[5]]
        XCTAssertEqual(vm.horizontalProducts.count, 3)
        XCTAssertEqual(vm.horizontalProducts[0].map { $0.id }, [1, 2])
        XCTAssertEqual(vm.horizontalProducts[1].map { $0.id }, [3, 4])
        XCTAssertEqual(vm.horizontalProducts[2].map { $0.id }, [5])

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    @MainActor
    func testFetch_failure_setsErrorAndStopsLoading() async {
        // Given: make the mock throw
        let vm = ProductViewModel(api: MockAPI(all: [], limited: [], shouldThrow: true))

        // When
        await vm.fetch()

        // Then
        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertEqual(vm.allProducts.count, 0)
        XCTAssertEqual(vm.horizontalProducts.count, 0)
    }
}
