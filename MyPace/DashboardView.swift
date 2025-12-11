import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Estatísticas gerais
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Total de Corridas",
                            value: "\(runs.count)",
                            icon: "figure.run",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Distância Total",
                            value: String(format: "%.1f km", totalDistance),
                            icon: "map",
                            color: .green
                        )
                    }
                    
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Tempo Total",
                            value: formatTotalTime(),
                            icon: "clock",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Pace Médio",
                            value: String(format: "%.2f min/km", averagePace),
                            icon: "speedometer",
                            color: .purple
                        )
                    }
                    
                    // Gráfico de distância por dia
                    if !runs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Distância por Dia")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart(last7Runs) { run in
                                BarMark(
                                    x: .value("Data", run.date, unit: .day),
                                    y: .value("Distância", run.distanceKm)
                                )
                                .foregroundStyle(.blue.gradient)
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Gráfico de pace
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pace por Dia")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart(last7Runs) { run in
                                LineMark(
                                    x: .value("Data", run.date, unit: .day),
                                    y: .value("Pace", run.pace)
                                )
                                .foregroundStyle(.purple.gradient)
                                .symbol(Circle())
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("Nenhuma corrida registrada")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("Adicione sua primeira corrida para ver estatísticas")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    }
                }
                .padding()
            }
            .navigationTitle("Início")
        }
    }
    
    private var totalDistance: Double {
        runs.reduce(0) { $0 + $1.distanceKm }
    }
    
    private var totalTime: Double {
        runs.reduce(0) { $0 + $1.timeMinutes }
    }
    
    private var averagePace: Double {
        guard !runs.isEmpty else { return 0 }
        let totalPace = runs.reduce(0.0) { $0 + $1.pace }
        return totalPace / Double(runs.count)
    }
    
    private func formatTotalTime() -> String {
        let hours = Int(totalTime) / 60
        let minutes = Int(totalTime) % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private var last7Runs: [Run] {
        Array(runs.prefix(7).reversed())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Run.self, inMemory: true)
}
