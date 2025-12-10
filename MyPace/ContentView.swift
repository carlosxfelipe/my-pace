//
//  ContentView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI

struct ContentView: View {
    
    // Callback para salvar a corrida no "dono" dessa tela
    var onSave: (Run) -> Void = { _ in }
    
    @State private var timeMinutes: String = ""
    @State private var distanceKm: String = ""
    @State private var date: Date = Date()
    
    var pace: Double? {
        guard let time = Double(timeMinutes),
              let distance = Double(distanceKm),
              distance > 0 else { return nil }
        
        return time / distance
    }
    
    var isFormValid: Bool {
        pace != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Informações da Corrida") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tempo (minutos)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Ex: 30", text: $timeMinutes)
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distância (km)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Ex: 5", text: $distanceKm)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Data", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "pt_BR"))
                }
                
                Section("Pace") {
                    if let paceValue = pace {
                        Text(String(format: "%.2f min/km", paceValue))
                    } else {
                        Text("Digite tempo e distância")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Button {
                        saveRun()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Salvar corrida")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("My Pace")
        }
    }
    
    private func saveRun() {
        guard let time = Double(timeMinutes),
              let distance = Double(distanceKm),
              distance > 0 else { return }
        
        let newRun = Run(
            date: date,
            distanceKm: distance,
            timeMinutes: time
        )
        
        onSave(newRun)
        
        // Limpa os campos após salvar
        timeMinutes = ""
        distanceKm = ""
        date = Date()
    }
}

#Preview {
    ContentView()
}
