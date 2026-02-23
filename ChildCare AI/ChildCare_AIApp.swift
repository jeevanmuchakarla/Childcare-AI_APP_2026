import SwiftUI

@main
struct ChildCare_AIApp: App {
    @StateObject private var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRouter)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        Group {
            switch appRouter.currentScreen {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .roleSelection:
                RoleSelectionView()
            case .login:
                LoginView()
            case .forgotPassword:
                ForgotPasswordView()
            case .createAccount(let role):
                CreateAccountView(role: role)
            case .home(let role):
                switch role {
                case .parent:
                    ParentTabView()
                case .preschool, .daycare, .babysitter:
                    ProviderTabView(role: role)
                case .admin:
                    AdminTabView()
                }
            }
        }
        .animation(.easeInOut, value: appRouter.currentScreen)
    }
}


