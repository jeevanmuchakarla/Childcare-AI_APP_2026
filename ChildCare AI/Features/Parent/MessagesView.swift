import SwiftUI

public struct MessagesView: View {
    @State private var searchText = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Parent Messages")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Search Bar
                HStack {
                    TextField("Search parents", text: $searchText)
                        .font(.body)
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ParentMessageRow(
                            name: "Sarah Johnson",
                            message: "Can you come 15 mins early?",
                            time: "10:30 AM",
                            unreadCount: 1,
                            initial: "SJ",
                            color: .blue
                        )
                        
                        ParentMessageRow(
                            name: "Mike Davis",
                            message: "Thanks for last night!",
                            time: "Yesterday",
                            unreadCount: 0,
                            initial: "MD",
                            color: Color(hex: "#FFD700")
                        )
                    }
                }
            }
        }
    }
}

struct ParentMessageRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let message: String
    let time: String
    let unreadCount: Int
    let initial: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
                Text(initial)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if name == "Sarah Johnson" {
                    Image(systemName: "person.fill") // Placeholder for real image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                
                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(themeManager.primaryColor)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 2, y: -2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
    }
}
