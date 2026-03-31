import Foundation
import Combine
import SwiftUI

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError
    case serverError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received from server."
        case .invalidResponse: return "Invalid response from server."
        case .decodingError: return "Failed to process server response."
        case .serverError(let message): return message
        }
    }
}

public class AuthService: ObservableObject {
    public static let shared = AuthService()
    
    // Use localhost for simulator development.
    // If testing on physical device, use your Mac's LAN IP (e.g., http://192.168.1.x:8000/api)
    public var baseURL: String {
        return "http://180.235.121.245:8018/api"
    }
    private var authBaseURL: String { "\(baseURL)/auth" }
    
    // Dedicated URLSession with optimised timeouts
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15   // seconds to wait for connection
        config.timeoutIntervalForResource = 20  // total request time
        config.waitsForConnectivity = false     // fail fast, don't queue
        return URLSession(configuration: config)
    }()

    @Published public var isAuthenticated = false
    @Published public var currentUser: UserProfile?
    @Published public var isPendingApproval = false
    @Published public var profileImageUpdateTrigger = UUID()
    
    public func triggerProfileImageReload() {
        DispatchQueue.main.async {
            self.profileImageUpdateTrigger = UUID()
        }
    }
    
    // Persistence
    @AppStorage("storedUserEmail") private var storedEmail: String = ""
    @AppStorage("storedUserRole") private var storedRole: String = ""
    @AppStorage("storedUserId") private var storedUserId: Int = -1
    @AppStorage("storedUserFullName") private var storedFullName: String = ""
    @AppStorage("storedAuthToken") public var storedToken: String = ""
    @AppStorage("isUserAuthenticated") private var isUserAuthenticated: Bool = false
    @AppStorage("hasSeenOnboarding") public var hasSeenOnboarding: Bool = false
    
    private init() {
        restoreSession()
    }
    
    private func restoreSession() {
        if isUserAuthenticated && !storedEmail.isEmpty && !storedRole.isEmpty && storedUserId != -1 {
            self.isAuthenticated = true
            let roleEnum = UserRole(rawValue: storedRole) ?? .parent
            self.currentUser = UserProfile(
                id: storedUserId,
                email: storedEmail,
                role: roleEnum,
                createdAt: nil,
                full_name: storedFullName.isEmpty ? nil : storedFullName
            )
        }
    }
    
    // MARK: - Login
    public func login(email: String, password: String) async throws -> UserProfile {
        guard let url = URL(string: "\(authBaseURL)/login") else {
            throw NetworkError.invalidURL
        }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        return try await performAuthRequest(url: url, body: body)
    }
    
    // MARK: - Register
    public func register(payload: [String: Any]) async throws -> UserProfile {
        guard let url = URL(string: "\(authBaseURL)/register") else {
            throw NetworkError.invalidURL
        }
        
        return try await performAuthRequest(url: url, body: payload)
    }
    
    // MARK: - Forgot Password
    public func forgotPassword(email: String) async throws -> String {
        guard let url = URL(string: "\(authBaseURL)/forgot-password") else {
            throw NetworkError.invalidURL
        }
        
        let body = ["email": email]
        let (data, _) = try await performCustomRequest(url: url, body: body)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        return response["message"] ?? "OTP sent"
    }
    
    public func verifyOTP(email: String, code: String) async throws -> String {
        guard let url = URL(string: "\(authBaseURL)/verify-otp") else {
            throw NetworkError.invalidURL
        }
        
        let body = ["email": email, "code": code]
        let (data, _) = try await performCustomRequest(url: url, body: body)
        
        // After verifying OTP, if it returns a user/profile info, update it.
        // For now just return the message but ensure we handle the response type if it changes.
        let response = try JSONDecoder().decode([String: String].self, from: data)
        return response["message"] ?? "OTP verified"
    }
    
    public func resetPassword(email: String, code: String, newPassword: String) async throws -> String {
        guard let url = URL(string: "\(authBaseURL)/reset-password") else {
            throw NetworkError.invalidURL
        }
        
        let body = [
            "email": email,
            "code": code,
            "new_password": newPassword
        ]
        let (data, _) = try await performCustomRequest(url: url, body: body)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        return response["message"] ?? "Password reset successfully"
    }
    
    private func performCustomRequest(url: URL, body: [String: Any]) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await BaseService.sharedServiceSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorData.detail)
            }
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        return (data, response)
    }
    
    // MARK: - Internal Helper
    private func performAuthRequest(url: URL, body: [String: Any]) async throws -> UserProfile {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Timeout is controlled by the custom URLSession configuration (15s request, 20s resource)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw NetworkError.noData
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorData.detail)
                }
                throw NetworkError.serverError("Server returned status \(httpResponse.statusCode)")
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                DispatchQueue.main.async {
                    if authResponse.status == "pending_approval" {
                        self.isPendingApproval = true
                        self.isAuthenticated = false
                        self.currentUser = authResponse.user
                    } else {
                        self.isPendingApproval = false
                        self.isAuthenticated = true
                        self.currentUser = authResponse.user
                        self.storedEmail = authResponse.user.email
                        self.storedRole = authResponse.user.role.rawValue
                        self.storedUserId = authResponse.user.id
                        self.storedFullName = authResponse.user.full_name ?? ""
                        self.storedToken = authResponse.token ?? ""
                        self.isUserAuthenticated = true
                    }
                }
                return authResponse.user
            } catch {
                throw NetworkError.decodingError
            }
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                throw NetworkError.serverError("The request timed out. Please check your internet connection and try again.")
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.serverError("No internet connection. Please check your network settings.")
            case .cannotConnectToHost, .cannotFindHost:
                throw NetworkError.serverError("Cannot connect to the server. Please try again later.")
            default:
                throw NetworkError.serverError("Network error: \(urlError.localizedDescription)")
            }
        }
    }
    
    public func checkServerConnection() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    public func logout() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.isPendingApproval = false
            self.currentUser = nil
            
            // Clear persistence
            self.storedEmail = ""
            self.storedRole = ""
            self.storedUserId = -1
            self.storedFullName = ""
            self.storedToken = ""
            self.isUserAuthenticated = false
        }
    }
    
    public func updateUserRecord(fullName: String?) {
        DispatchQueue.main.async {
            if let user = self.currentUser {
                self.currentUser = UserProfile(
                    id: user.id,
                    email: user.email,
                    role: user.role,
                    createdAt: user.createdAt,
                    full_name: fullName
                )
                self.storedFullName = fullName ?? ""
            }
        }
    }
}

// MARK: - API Response Models
public struct AuthResponse: Codable {
    public let message: String
    public let status: String?
    public let token: String?
    public let user: UserProfile
}

public struct ErrorResponse: Codable {
    public let detail: String
}

public struct UserProfile: Codable {
    public let id: Int
    public let email: String
    public let role: UserRole
    public let createdAt: String?
    public let full_name: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, role
        case createdAt = "created_at"
        case full_name
    }
}
