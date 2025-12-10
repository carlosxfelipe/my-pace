//
//  SettingsView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    @State private var notificationsEnabled = false
    
    var body: some View {
        NavigationStack {
            Form {
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
            }
            .navigationTitle("Configurações")
        }
    }
}

#Preview {
    SettingsView()
}
