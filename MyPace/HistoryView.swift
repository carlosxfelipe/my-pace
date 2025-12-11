//
//  HistoryView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    let runs: [Run]
    let modelContext: ModelContext
    let authManager: AuthManager
    let syncManager: SyncManager
    
    @State private var showClearAllConfirmation = false
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "pt_BR")
        return df
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
                } else {
                    List {
                        ForEach(runs) { run in
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
                                
                                Text(dateFormatter.string(from: run.date))
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
            .toolbar {
                if !runs.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showClearAllConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
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
