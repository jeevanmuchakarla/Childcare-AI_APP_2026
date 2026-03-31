import SwiftUI

struct AdminCapacityView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var capacityData: CapacityStats?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("Active Capacity")
                    .font(.headline.bold())
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(themeManager.primaryColor)
            }
            .padding()
            .background(AppTheme.surface)
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Main Gauge
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 20)
                                    .frame(width: 200, height: 200)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat((Double(capacityData?.availability_percentage.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0) / 100.0))
                                    .stroke(
                                        LinearGradient(colors: [themeManager.primaryColor, themeManager.primaryColor.opacity(0.6)], startPoint: .top, endPoint: .bottom),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text(capacityData?.availability_percentage ?? "0%")
                                        .font(.system(size: 40, weight: .bold))
                                    Text("Utilized")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text(capacityData?.trend ?? "Loading trend...")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(30)
                        .background(AppTheme.surface)
                        .cornerRadius(30)
                        
                        // Breakdown
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Current Breakdown")
                                .font(.headline)
                            
                            CapacityRow(title: "Occupied Seats", value: capacityData?.occupied_seats ?? 0, total: capacityData?.total_capacity ?? 1, color: themeManager.primaryColor)
                            CapacityRow(title: "Available Spots", value: (capacityData?.total_capacity ?? 0) - (capacityData?.occupied_seats ?? 0), total: capacityData?.total_capacity ?? 1, color: .green)
                        }
                        .padding(24)
                        .background(AppTheme.surface)
                        .cornerRadius(24)
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        Task {
            do {
                let data = try await AdminService.shared.fetchCapacityMetrics()
                await MainActor.run {
                    self.capacityData = data
                    self.isLoading = false
                }
            } catch {
                print("Error loading capacity: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

struct CapacityRow: View {
    let title: String
    let value: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
