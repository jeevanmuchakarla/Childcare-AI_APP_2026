import SwiftUI
import Combine
public enum AppScreen: Hashable {
    case splash
    case onboarding
    case roleSelection
    case login
    case forgotPassword
    case createAccount(UserRole)
    case home(UserRole)
}

public class AppRouter: ObservableObject {
    @Published public var currentScreen: AppScreen = .splash
    @Published public var currentRole: UserRole? = nil
    
    public init() {}
    
    public func navigate(to screen: AppScreen) {
        withAnimation {
            self.currentScreen = screen
        }
    }
    
    public func login(as role: UserRole) {
        self.currentRole = role
        navigate(to: .home(role))
    }
    
    public func logout() {
        self.currentRole = nil
        navigate(to: .login)
    }
}
