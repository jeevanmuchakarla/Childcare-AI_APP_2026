import SwiftUI

public struct ChildSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    let children: [ChildModel]
    let onSelect: (ChildModel) -> Void
    
    public init(children: [ChildModel], onSelect: @escaping (ChildModel) -> Void) {
        self.children = children
        self.onSelect = onSelect
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("Select Child")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Color.clear.frame(width: 30)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(children) { child in
                        Button(action: {
                            onSelect(child)
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(themeManager.primaryColor.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundColor(themeManager.primaryColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(child.name)
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(child.age ?? "Age not set")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}
