import SwiftUI

public struct ProviderTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    let role: UserRole
    @State private var selectedTab = 0
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ProviderHomeView(role: role)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // To be replaced
            ProviderBookingsView(role: role)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Bookings")
                }
                .tag(1)
            
            Text("Provider Children View")
                .tabItem {
                    Image(systemName: "face.smiling.fill")
                    Text("Children")
                }
                .tag(2)
            
            Text("Provider Chat View")
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(3)
            
            Text("Provider Settings")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(AppTheme.primary)
    }
}
