import Foundation

public struct BaseResponse: Codable {
    public let message: String
}

// MARK: - Core Networking Logic
public class BaseService {
    // MARK: - Shared optimised URLSession for all services (15s timeout, fail-fast)
    public static let sharedServiceSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity       = false
        config.urlCache                   = URLCache(memoryCapacity: 10_000_000,   // 10 MB memory
                                                     diskCapacity:   50_000_000,   // 50 MB disk
                                                     diskPath:       "service_cache")
        config.requestCachePolicy         = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()

    // MARK: - Shared JSON decoder (reused across all requests to avoid allocation overhead)
    public static let sharedDecoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    internal var baseURL: String { AuthService.shared.baseURL }

    internal func performRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let data = try await performDataRequest(endpoint: endpoint, method: method, body: body, queryItems: queryItems)

        // If T is Data, return raw data
        if T.self == Data.self {
            return data as! T
        }

        do {
            return try Self.sharedDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    internal func performRawRequest(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> [String: Any] {
        let data = try await performDataRequest(endpoint: endpoint, method: method, body: body, queryItems: queryItems)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.decodingError
        }
        return json
    }

    private func performDataRequest(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> Data {
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Attach JWT token if it exists
        let token = AuthService.shared.storedToken
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Disable caching
        request.cachePolicy = .reloadIgnoringLocalCacheData

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        // --- DEBUG LOGGING ---
        print("🚀 API REQUEST: \(method) \(url.absoluteString)")
        print("📁 HEADERS: \(request.allHTTPHeaderFields ?? [:])")
        if let body = body {
            print("📦 PAYLOAD: \(body)")
        }

        let (data, response) = try await Self.sharedServiceSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        print("✅ API RESPONSE: \(httpResponse.statusCode) (\(url.lastPathComponent))")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 BODY: \(responseString)")
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError("Server returned status \(httpResponse.statusCode)")
        }
        
        return data
    }

    // Keep internal for backward compatibility if needed, but endpoint version is preferred
    internal func performRequest<T: Decodable>(url: URL, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await Self.sharedServiceSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError("Server returned status \(httpResponse.statusCode)")
        }

        do {
            return try Self.sharedDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
