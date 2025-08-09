import Foundation

enum APIError: Error { case badURL, badResponse, decoding, network(Error) }

final class ApiClient {
    private let base = URL(string: "https://fakestoreapi.com")!
    private let session: URLSession = .shared
    
    func fetchAllProducts() async throws -> [Product] {
        let url = base.appendingPathComponent("products")
        return try await get(url)
    }

    /// limit for the horizontal (max 5)
    func fetchLimitedProducts(limit: Int = 5) async throws -> [Product] {
        var comp = URLComponents(url: base.appendingPathComponent("products"), resolvingAgainstBaseURL: false)!
        comp.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        guard let url = comp.url else { throw APIError.badURL }
        return try await get(url)
    }
    
    private func get<T: Decodable>(_ url: URL) async throws -> T {
        do {
            let (data, resp) = try await session.data(from: url)
            guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw APIError.badResponse
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        } catch {
            throw APIError.network(error)
        }
    }
}
