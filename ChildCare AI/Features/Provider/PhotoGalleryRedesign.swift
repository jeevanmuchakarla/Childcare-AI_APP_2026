import SwiftUI

public struct PhotoGalleryRedesign: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMonth = "All"
    
    let months = ["All", "Oct 2023", "Sep 2023", "Aug 2023"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Photo Gallery", trailingAction: AnyView(
                Button(action: { }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(themeManager.primaryColor)
                }
            ))
            
            // Month Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(months, id: \.self) { month in
                        Button(action: { selectedMonth = month }) {
                            Text(month)
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(selectedMonth == month ? themeManager.primaryColor : Color.white)
                                .foregroundColor(selectedMonth == month ? .white : .gray)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedMonth == month ? Color.clear : Color(hex: "#F1F4F9"), lineWidth: 1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            
            ScrollView {
                // Photo Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(0..<12) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#F1F4F9"))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(24)
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
    }
}
