import SwiftUI

public struct AdminTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            AdminHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            Text("Admin Childcare View")
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Childcare")
                }
                .tag(1)
            
            Text("Admin Users View")
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Users")
                }
                .tag(2)
            
            Text("Admin Reports View")
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                    Text("Reports")
                }
                .tag(3)
            
            Text("Admin Settings View")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.indigo) // Using Indigo to denote Admin privilege visually
    }
}
