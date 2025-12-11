//
//  RootView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    
    @State private var authManager = AuthManager.shared
    @State private var syncManager = SyncManager.shared
    
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    
    private var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some View {
        TabView {
            Tab("Início", systemImage: "house") {
                DashboardView()
            }
            
            Tab("Adicionar", systemImage: "plus.circle.fill") {
                AddRunView(
                    authManager: authManager,
                    syncManager: syncManager
                )
            }
            
            Tab("Histórico", systemImage: "clock.arrow.circlepath") {
                HistoryView(
                    runs: runs,
                    modelContext: modelContext,
                    authManager: authManager,
                    syncManager: syncManager
                )
            }
            
            Tab("Config.", systemImage: "gearshape") {
                SettingsView(
                    authManager: authManager,
                    syncManager: syncManager
                )
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    RootView()
}
