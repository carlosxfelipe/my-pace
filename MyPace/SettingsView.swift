//
//  SettingsView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    let authManager: AuthManager
    let syncManager: SyncManager
    
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    @State private var notificationsEnabled = false
    @State private var showLogin = false
    @State private var isSyncing = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Seção de Conta
                Section("Conta") {
                    if authManager.isLoggedIn {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Conectado")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let email = authManager.userEmail {
                                Text(email)
                                    .font(.body)
                            }
                        }
                        
                        Button {
                            Task {
                                await syncData()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text(isSyncing ? "Sincronizando..." : "Sincronizar agora")
                            }
                        }
                        .disabled(isSyncing)
                        
                        Button("Sair", role: .destructive) {
                            authManager.logout()
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Modo Offline")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("Seus dados estão salvos apenas neste dispositivo")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Button {
                            showLogin = true
                        } label: {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                Text("Fazer login")
                            }
                        }
                    }
                }
                
                Section("Aparência") {
                    Picker("Tema", selection: $selectedAppearance) {
                        Text("Sistema").tag("system")
                        Text("Claro").tag("light")
                        Text("Escuro").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notificações") {
                    Toggle("Notificações de treino", isOn: $notificationsEnabled)
                }
                
                if authManager.isLoggedIn, let lastSync = syncManager.lastSyncDate {
                    Section {
                        Text("Última sincronização: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Configurações")
            .sheet(isPresented: $showLogin) {
                LoginView(authManager: authManager, syncManager: syncManager)
            }
        }
    }
    
    private func syncData() async {
        isSyncing = true
        
        do {
            try await syncManager.syncFromAPI(
                modelContext: modelContext,
                authManager: authManager
            )
        } catch {
            print("Erro na sincronização: \(error)")
        }
        
        isSyncing = false
    }
}

#Preview {
    SettingsView(
        authManager: AuthManager.shared,
        syncManager: SyncManager.shared
    )
}
