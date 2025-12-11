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
        // 1. Se estiver logado, primeiro envia para API para obter o ID correto
        if let token = authManager.token {
            do {
                let apiRun = try await APIService.shared.createRun(
                    token: token,
                    date: run.date,
                    distanceKm: run.distanceKm,
                    timeMinutes: run.timeMinutes
                )
                
                // Cria corrida com o ID da API
                let newRun = Run(
                    id: apiRun.id,
                    date: apiRun.date,
                    distanceKm: Double(apiRun.distanceKm) ?? 0,
                    timeMinutes: Double(apiRun.timeMinutes) ?? 0
                )
                modelContext.insert(newRun)
                try modelContext.save()
                print("✅ Corrida salva localmente e na API com ID: \(apiRun.id)")
            } catch {
                print("⚠️ Erro ao sincronizar com API, salvando apenas localmente: \(error)")
                // Falha na API - salva localmente com ID local
                modelContext.insert(run)
                try modelContext.save()
            }
        } else {
            // 2. Se não estiver logado, salva apenas localmente
            modelContext.insert(run)
            try modelContext.save()
            print("✅ Corrida salva localmente (offline)")
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
            
            // Cria set de corridas locais por data/distância/tempo para detectar duplicatas
            let localRunsSet = Set(localRuns.map { run in
                "\(run.date.timeIntervalSince1970)_\(run.distanceKm)_\(run.timeMinutes)"
            })
            
            // Adiciona corridas que existem na API mas não localmente
            for apiRun in apiRuns {
                let apiDistance = Double(apiRun.distanceKm) ?? 0
                let apiTime = Double(apiRun.timeMinutes) ?? 0
                let apiKey = "\(apiRun.date.timeIntervalSince1970)_\(apiDistance)_\(apiTime)"
                
                // Verifica se já existe por ID ou por data/distância/tempo
                if !localIds.contains(apiRun.id) && !localRunsSet.contains(apiKey) {
                    // Converte APIRun para Run
                    let newRun = Run(
                        id: apiRun.id,
                        date: apiRun.date,
                        distanceKm: apiDistance,
                        timeMinutes: apiTime
                    )
                    modelContext.insert(newRun)
                    print("✅ Adicionando corrida da API: \(apiRun.id)")
                } else if localIds.contains(apiRun.id) {
                    print("⏭️ Corrida já existe (mesmo ID): \(apiRun.id)")
                } else {
                    print("⏭️ Corrida duplicada detectada (mesma data/distância/tempo)")
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
        
        // Cria set de corridas da API por data/distância/tempo para detectar duplicatas
        let apiRunsSet = Set(apiRuns.map { run in
            let distance = Double(run.distanceKm) ?? 0
            let time = Double(run.timeMinutes) ?? 0
            return "\(run.date.timeIntervalSince1970)_\(distance)_\(time)"
        })
        
        // Faz upload das corridas que só existem localmente
        for run in localRuns where !apiIds.contains(run.id) {
            let runKey = "\(run.date.timeIntervalSince1970)_\(run.distanceKm)_\(run.timeMinutes)"
            
            // Verifica se já existe uma corrida igual na API
            if apiRunsSet.contains(runKey) {
                print("⏭️ Corrida local já existe na API (mesma data/distância/tempo), pulando upload")
                // Remove a corrida local duplicada
                modelContext.delete(run)
                continue
            }
            
            do {
                let apiRun = try await APIService.shared.createRun(
                    token: token,
                    date: run.date,
                    distanceKm: run.distanceKm,
                    timeMinutes: run.timeMinutes
                )
                
                // Remove a corrida local antiga (com ID diferente)
                modelContext.delete(run)
                
                // Adiciona a nova corrida com o ID da API
                let newRun = Run(
                    id: apiRun.id,
                    date: apiRun.date,
                    distanceKm: Double(apiRun.distanceKm) ?? 0,
                    timeMinutes: Double(apiRun.timeMinutes) ?? 0
                )
                modelContext.insert(newRun)
                
                print("✅ Corrida local sincronizada com API (ID: \(apiRun.id))")
            } catch {
                print("⚠️ Erro ao enviar corrida: \(error)")
            }
        }
        
        try modelContext.save()
    }
}
