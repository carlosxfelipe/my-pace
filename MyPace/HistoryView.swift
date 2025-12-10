//
//  HistoryView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI

struct HistoryView: View {
    let runs: [Run]
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if runs.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma corrida salva",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Salve uma corrida na aba My Pace para vê-la aqui.")
                    )
                } else {
                    List(runs.sorted { $0.date > $1.date }) { run in
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
                }
            }
            .navigationTitle("Histórico")
        }
    }
}

#Preview {
    HistoryView(runs: [])
}
