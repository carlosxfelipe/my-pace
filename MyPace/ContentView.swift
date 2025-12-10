//
//  ContentView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var timeMinutes: String = ""
    @State private var distanceKm: String = ""
    @State private var date: Date = Date()
    
    var pace: Double? {
        guard let time = Double(timeMinutes),
              let distance = Double(distanceKm),
              distance > 0 else { return nil }
        
        return time / distance
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Informações da Corrida") {
                    TextField("Tempo (min)", text: $timeMinutes)
                        .keyboardType(.decimalPad)
                    
                    TextField("Distância (km)", text: $distanceKm)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Data", selection: $date, displayedComponents: .date)
                }
                
                Section("Pace") {
                    if let paceValue = pace {
                        Text(String(format: "%.2f min/km", paceValue))
                    } else {
                        Text("Digite tempo e distância")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("My Pace")
        }
    }
}

#Preview {
    ContentView()
}
