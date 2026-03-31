import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Appearance")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Theme Mode Toggle removed as requested

                    // Color Picker
                    DashboardSection(title: "Choose Your Theme") {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select a color palette that fits your style")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                                ForEach(AppTheme.ColorPreset.allCases) { preset in
                                    ColorOptionCard(
                                        hex: preset.rawValue,
                                        name: preset.name,
                                        isSelected: themeManager.primaryColorHex == preset.rawValue,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                themeManager.updatePreset(preset)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .padding(.top, 12)
                    }
                    
                    // Preview completely removed as requested
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ColorOptionCard: View {
    let hex: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 40, height: 40)
                        .shadow(color: Color(hex: hex).opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color(hex: hex).opacity(0.08) : AppTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: hex) : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
