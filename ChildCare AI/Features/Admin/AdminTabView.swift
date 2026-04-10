import SwiftUI

public struct AdminTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageStore: MessageStore
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                AdminDashboardView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                AdminAllBookingsView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Bookings")
            }
            .tag(1)
            
            NavigationStack {
                AdminManagementView(selectedTab: $selectedTab, initialTab: 0)
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Users")
            }
            .tag(2)
            
            NavigationStack {
                AdminMessagesView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Messages")
            }
            .tag(3)
            
            NavigationStack {
                SettingsDashboardView(role: .admin)
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
