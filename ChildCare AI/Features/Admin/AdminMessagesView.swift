import SwiftUI

public struct AdminMessagesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Messages")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal)
                    .padding(.top)
                
                Text("Select a category to start real-time chat")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal)
                
                VStack(spacing: 20) {
                    MessageCategoryButton(
                        title: "Parents",
                        subtitle: "Chat with registered parents",
                        icon: "person.2.fill",
                        color: Color(hex: "#7D61FF"),
                        destination: ChatView(role: .admin, initialCategory: "Parent")
                    )
                    
                    MessageCategoryButton(
                        title: "Preschools",
                        subtitle: "Communication with preschool centers",
                        icon: "building.columns.fill",
                        color: Color(hex: "#00BC8C"),
                        destination: ChatView(role: .admin, initialCategory: "Preschool")
                    )
                    
                    MessageCategoryButton(
                        title: "Daycares",
                        subtitle: "Coordination with daycare providers",
                        icon: "house.fill",
                        color: Color(hex: "#FFAC33"),
                        destination: ChatView(role: .admin, initialCategory: "Daycare")
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct MessageCategoryButton<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(20)
            .background(AppTheme.surface)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        AdminMessagesView()
            .environmentObject(ThemeManager())
    }
}
