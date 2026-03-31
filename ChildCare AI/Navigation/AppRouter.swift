import SwiftUI
import Combine
public enum AppScreen: Hashable {
    case splash
    case onboarding
    case roleSelection
    case login(UserRole)
    case adminLogin
    case forgotPassword
    case adminRegistration
    case createAccount(UserRole)
    case home(UserRole)
}

public class AppRouter: ObservableObject {
    @Published public var currentScreen: AppScreen = .splash
    @Published public var currentRole: UserRole? = nil
    @AppStorage("isDarkMode") public var isDarkMode = false
    
    public init() {
        // Enforce the permanent app flow: always start with Splash flow as requested.
        self.currentScreen = .splash
    }
    
    public func navigate(to screen: AppScreen) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            self.currentScreen = screen
        }
    }
    
    public func login(as role: UserRole) {
        self.currentRole = role
        if !AuthService.shared.isAuthenticated {
            AuthService.shared.isAuthenticated = true
        }
        navigate(to: .home(role))
    }
    
    public func logout() {
        self.currentRole = nil
        AuthService.shared.logout()
        navigate(to: .roleSelection)
    }
}
