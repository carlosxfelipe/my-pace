//
//  RootView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI

struct RootView: View {
    @State private var selectedTab: MainTab = .run
    @State private var runs: [Run] = []
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    
    private var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Group {
                switch selectedTab {
                case .run:
                    ContentView { newRun in
                        runs.append(newRun)
                    }
                    
                case .history:
                    HistoryView(runs: $runs)
                    
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GlassBottomBar(selectedTab: $selectedTab)
        }
        // garante que a barra não seja empurrada pelo teclado
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    RootView()
}
