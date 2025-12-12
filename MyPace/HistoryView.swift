//
//  HistoryView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI
import SwiftData

enum RunFilter: String, CaseIterable {
    case all = "Todos"
    case last7Days = "7 dias"
    case last30Days = "30 dias"
    case last3Months = "3 meses"
}

struct HistoryView: View {
    let runs: [Run]
    let modelContext: ModelContext
    let authManager: AuthManager
    let syncManager: SyncManager
    
    @State private var showClearAllConfirmation = false
    @State private var selectedFilter: RunFilter = .all
    @State private var searchText = ""
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "pt_BR")
        return df
    }
    
    private func formattedDateWithWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        let dateString = formatter.string(from: date)
        return dateString.prefix(1).uppercased() + dateString.dropFirst()
    }
    
    private var filteredRuns: [Run] {
        var filtered = runs
        
        // Filtro por período
        let now = Date()
        switch selectedFilter {
        case .all:
            break
        case .last7Days:
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
            filtered = filtered.filter { $0.date >= sevenDaysAgo }
        case .last30Days:
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!
            filtered = filtered.filter { $0.date >= thirtyDaysAgo }
        case .last3Months:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: now)!
            filtered = filtered.filter { $0.date >= threeMonthsAgo }
        }
        
        // Filtro por busca (distância ou pace)
        if !searchText.isEmpty {
            filtered = filtered.filter { run in
                let distanceStr = String(format: "%.2f", run.distanceKm)
                let paceStr = String(format: "%.2f", run.pace)
                return distanceStr.contains(searchText) || paceStr.contains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if runs.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma corrida salva",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Salve uma corrida na aba Início para vê-la aqui.")
                    )
                } else if filteredRuns.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma corrida encontrada",
                        systemImage: "magnifyingglass",
                        description: Text("Tente ajustar os filtros ou busca.")
                    )
                } else {
                    List {
                        Section {
                            Picker("Período", selection: $selectedFilter) {
                                ForEach(RunFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Section {
                            Text("\(filteredRuns.count) corrida\(filteredRuns.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        ForEach(filteredRuns) { run in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: "%.2f min/km", run.pace))
                                    .font(.headline)
                                
                                HStack {
                                    Text(String(format: "%.2f km", run.distanceKm))
                                    Text("•")
                                    Text(String(format: "%.0f min", run.timeMinutes))
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                
                                Text(formattedDateWithWeekday(run.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            deleteRuns(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Histórico")
            .if(!runs.isEmpty) { view in
                view.searchable(text: $searchText, prompt: "Buscar por distância ou pace")
            }
            .toolbar {
                if !runs.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showClearAllConfirmation = true
                            } label: {
                                Label("Limpar tudo", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                }
            }
            .alert("Limpar Todos os Registros", isPresented: $showClearAllConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpar Tudo", role: .destructive) {
                    clearAllRuns()
                }
            } message: {
                Text("Tem certeza que deseja deletar todas as \(runs.count) corridas? Esta ação não pode ser desfeita.")
            }
        }
    }
    
    private func deleteRuns(at offsets: IndexSet) {
        for index in offsets {
            let run = runs[index]
            
            // Deleta usando SyncManager (local + API se logado)
            Task {
                do {
                    try await syncManager.deleteRun(
                        run,
                        modelContext: modelContext,
                        authManager: authManager
                    )
                } catch {
                    print("Erro ao deletar: \(error)")
                }
            }
        }
    }
    
    private func clearAllRuns() {
        Task {
            for run in runs {
                do {
                    try await syncManager.deleteRun(
                        run,
                        modelContext: modelContext,
                        authManager: authManager
                    )
                } catch {
                    print("Erro ao deletar: \(error)")
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Run.self, configurations: config)
    
    return HistoryView(
        runs: [],
        modelContext: container.mainContext,
        authManager: AuthManager.shared,
        syncManager: SyncManager.shared
    )
}
