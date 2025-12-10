//
//  SyncManager.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 10/12/25.
//

import Foundation
import SwiftData

@Observable
class SyncManager {
    static let shared = SyncManager()
    
    var isSyncing = false
    var lastSyncDate: Date?
    
    private init() {}
    
    /// Salva corrida: sempre no SwiftData local, e na API se estiver logado
    func saveRun(
        _ run: Run,
        modelContext: ModelContext,
        authManager: AuthManager
    ) async throws {
        // 1. Salva localmente sempre
        modelContext.insert(run)
        try modelContext.save()
        
        // 2. Se estiver logado, sincroniza com API
        if let token = authManager.token {
            Task {
                do {
                    _ = try await APIService.shared.createRun(
                        token: token,
                        date: run.date,
                        distanceKm: run.distanceKm,
                        timeMinutes: run.timeMinutes
                    )
                    print("✅ Corrida sincronizada com API")
                } catch {
                    print("⚠️ Erro ao sincronizar com API: \(error)")
                    // Falha silenciosa - dados ficam salvos localmente
                }
            }
        }
    }
    
    /// Deleta corrida: remove do SwiftData local, e da API se estiver logado
    func deleteRun(
        _ run: Run,
        modelContext: ModelContext,
        authManager: AuthManager
    ) async throws {
        let runId = run.id
        
        // 1. Deleta localmente
        modelContext.delete(run)
        try modelContext.save()
        
        // 2. Se estiver logado, deleta da API
        if let token = authManager.token {
            Task {
                do {
                    try await APIService.shared.deleteRun(token: token, runId: runId)
                    print("✅ Corrida deletada da API")
                } catch {
                    print("⚠️ Erro ao deletar da API: \(error)")
                }
            }
        }
    }
    
    /// Sincroniza dados da API para o SwiftData local (chamado após login)
    func syncFromAPI(
        modelContext: ModelContext,
        authManager: AuthManager
    ) async throws {
        guard let token = authManager.token else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // Busca corridas da API
            let apiRuns = try await APIService.shared.fetchRuns(token: token)
            
            // Busca corridas locais
            let descriptor = FetchDescriptor<Run>()
            let localRuns = try modelContext.fetch(descriptor)
            let localIds = Set(localRuns.map { $0.id })
            
            // Adiciona corridas que existem na API mas não localmente
            for apiRun in apiRuns {
                if !localIds.contains(apiRun.id) {
                    // Converte APIRun para Run
                    let newRun = Run(
                        id: apiRun.id,
                        date: apiRun.date,
                        distanceKm: Double(apiRun.distanceKm) ?? 0,
                        timeMinutes: Double(apiRun.timeMinutes) ?? 0
                    )
                    modelContext.insert(newRun)
                }
            }
            
            try modelContext.save()
            lastSyncDate = Date()
            print("✅ Sincronização completa: \(apiRuns.count) corridas da API")
            
        } catch {
            print("❌ Erro na sincronização: \(error)")
            throw error
        }
    }
    
    /// Faz upload de corridas locais que ainda não estão na API (após login)
    func uploadLocalRuns(
        modelContext: ModelContext,
        authManager: AuthManager
    ) async throws {
        guard let token = authManager.token else { return }
        
        // Busca corridas locais
        let descriptor = FetchDescriptor<Run>()
        let localRuns = try modelContext.fetch(descriptor)
        
        // Busca IDs da API
        let apiRuns = try await APIService.shared.fetchRuns(token: token)
        let apiIds = Set(apiRuns.map { $0.id })
        
        // Faz upload das corridas que só existem localmente
        for run in localRuns where !apiIds.contains(run.id) {
            do {
                _ = try await APIService.shared.createRun(
                    token: token,
                    date: run.date,
                    distanceKm: run.distanceKm,
                    timeMinutes: run.timeMinutes
                )
                print("✅ Corrida local enviada para API")
            } catch {
                print("⚠️ Erro ao enviar corrida: \(error)")
            }
        }
    }
}
