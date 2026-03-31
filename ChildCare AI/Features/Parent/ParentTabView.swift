import SwiftUI

public struct ParentTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageStore: MessageStore
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ParentHomeView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                ParentBookingsView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Bookings")
            }
            .tag(1)
            
            NavigationStack {
                ChildrenTabView(role: .parent)
            }
            .tabItem {
                Image(systemName: "figure.and.child.holdinghands")
                Text("Children")
            }
            .tag(2)
            
            NavigationStack {
                ChatView(role: .parent)
            }
            .tabItem {
                Label("Chat", systemImage: "message")
            }
            .badge(messageStore.totalUnread > 0 ? messageStore.totalUnread : 0)
            .tag(3)
            
            NavigationStack {
                SettingsDashboardView(role: .parent)
            }
            .tabItem {
                Image(systemName: "gearshape")
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
