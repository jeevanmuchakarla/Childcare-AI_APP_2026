import SwiftUI

public struct ProviderTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageStore: MessageStore
    let role: UserRole
    @State private var selectedTab = 0
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                Group {
                    ProviderDashboardView()
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                ProviderBookingsView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Bookings")
            }
            .tag(1)
            
            NavigationStack {
                ProviderChildrenOverview(role: role)
            }
            .tabItem {
                Image(systemName: "face.smiling.fill")
                Text("Children")
            }
            .tag(2)
            
            NavigationStack {
                ChatView(role: role)
            }
            .tabItem {
                Label("Chat", systemImage: "message.fill")
            }
            .badge(messageStore.totalUnread > 0 ? messageStore.totalUnread : 0)
            .tag(3)
            
            NavigationStack {
                SettingsDashboardView(role: role)
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(4)
        }
        .accentColor(themeManager.primaryColor)
        .onAppear {
            if let userId = AuthService.shared.currentUser?.id {
                messageStore.startBadgePolling(userId: userId)
            }
        }
    }
}
