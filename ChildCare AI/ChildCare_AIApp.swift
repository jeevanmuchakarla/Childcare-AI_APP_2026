import SwiftUI

@main
struct ChildCare_AIApp: App {
    @StateObject private var appRouter = AppRouter()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var bookingStore = BookingStore()
    @StateObject private var childStore = ChildStore()
    @StateObject private var messageStore = MessageStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRouter)
                .environmentObject(themeManager)
                .environmentObject(bookingStore)
                .environmentObject(childStore)
                .environmentObject(messageStore)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            Group {
                switch appRouter.currentScreen {
                case .splash:
                    SplashView()
                case .onboarding:
                    OnboardingView()
                case .roleSelection:
                    RoleSelectionView()
                case .login(let role):
                    LoginView(role: role)
                        .id(role)
                case .adminLogin:
                    AdminLoginView()
                case .forgotPassword:
                    ForgotPasswordView()
                case .adminRegistration:
                    AdminAccessView()
                case .createAccount(let role):
                    CreateAccountView(role: role)
                case .home(let role):
                    switch role {
                    case .parent:
                        ParentTabView()
                    case .preschool, .daycare:
                        ProviderTabView(role: role)
                    case .admin:
                        AdminTabView()
                    }
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            .animation(.easeInOut(duration: 0.4), value: appRouter.currentScreen)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .id(themeManager.primaryColorHex)
    }
}


