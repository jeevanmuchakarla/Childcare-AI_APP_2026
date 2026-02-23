import SwiftUI

public struct ParentTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ParentHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // To be replaced by actual views in later phases
            Text("Bookings View")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Bookings")
                }
                .tag(1)
            
            Text("Children View")
                .tabItem {
                    Image(systemName: "face.smiling.fill")
                    Text("Children")
                }
                .tag(2)
            
            Text("Chat View")
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(3)
            
            Text("Settings View")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(AppTheme.primary)
    }
}
