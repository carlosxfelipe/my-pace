import Foundation
import SwiftData

@Model
class Run {
    @Attribute(.unique) var id: UUID
    var date: Date
    var distanceKm: Double
    var timeMinutes: Double
    
    var pace: Double {
        timeMinutes / distanceKm
    }
    
    init(id: UUID = UUID(), date: Date, distanceKm: Double, timeMinutes: Double) {
        self.id = id
        self.date = date
        self.distanceKm = distanceKm
        self.timeMinutes = timeMinutes
    }
}

/* ============================================
   BACKEND API - PostgreSQL Queries (Neon DB)
   ============================================

   Tabela SQL:
   
   CREATE TABLE runs (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       user_id UUID NOT NULL REFERENCES users(id),
       date TIMESTAMP NOT NULL,
       distance_km DECIMAL(10,2) NOT NULL,
       time_minutes DECIMAL(10,2) NOT NULL,
       created_at TIMESTAMP DEFAULT NOW(),
       updated_at TIMESTAMP DEFAULT NOW()
   );
   
   CREATE INDEX idx_runs_user_date ON runs(user_id, date DESC);
   
   ============================================
   REST API Endpoints:
   ============================================
   
   1. GET /api/runs
      Buscar todas as corridas do usuário
      
      SELECT id, date, distance_km, time_minutes 
      FROM runs 
      WHERE user_id = $1 
      ORDER BY date DESC;
   
   -------------------------------------------
   
   2. POST /api/runs
      Criar nova corrida
      Body: { "date": "2025-12-09T10:00:00Z", "distanceKm": 5.0, "timeMinutes": 30.0 }
      
      INSERT INTO runs (user_id, date, distance_km, time_minutes)
      VALUES ($1, $2, $3, $4)
      RETURNING id, date, distance_km, time_minutes;
   
   -------------------------------------------
   
   3. DELETE /api/runs/:id
      Deletar corrida
      
      DELETE FROM runs 
      WHERE id = $1 AND user_id = $2;
   
   -------------------------------------------
   
   4. GET /api/runs/sync?last_sync=2025-12-09T10:00:00Z
      Sincronização incremental
      
      SELECT id, date, distance_km, time_minutes, updated_at
      FROM runs 
      WHERE user_id = $1 AND updated_at > $2
      ORDER BY updated_at DESC;
   
   -------------------------------------------
   
   5. GET /api/runs/stats
      Estatísticas do usuário
      
      SELECT 
          COUNT(*) as total_runs,
          SUM(distance_km) as total_distance,
          AVG(time_minutes / distance_km) as avg_pace,
          MIN(time_minutes / distance_km) as best_pace
      FROM runs 
      WHERE user_id = $1;
   
   ============================================
   Implementação Swift (HTTP Client):
   ============================================
   
   struct RunAPI {
       static let baseURL = "https://your-api.com/api"
       
       // GET todas as corridas
       static func fetchRuns() async throws -> [Run] {
           let url = URL(string: "\(baseURL)/runs")!
           var request = URLRequest(url: url)
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           
           let (data, _) = try await URLSession.shared.data(for: request)
           return try JSONDecoder().decode([Run].self, from: data)
       }
       
       // POST nova corrida
       static func createRun(_ run: Run) async throws {
           let url = URL(string: "\(baseURL)/runs")!
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.httpBody = try JSONEncoder().encode(run)
           
           let (_, response) = try await URLSession.shared.data(for: request)
           guard (response as? HTTPURLResponse)?.statusCode == 201 else {
               throw URLError(.badServerResponse)
           }
       }
       
       // DELETE corrida
       static func deleteRun(id: UUID) async throws {
           let url = URL(string: "\(baseURL)/runs/\(id)")!
           var request = URLRequest(url: url)
           request.httpMethod = "DELETE"
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           
           let (_, response) = try await URLSession.shared.data(for: request)
           guard (response as? HTTPURLResponse)?.statusCode == 204 else {
               throw URLError(.badServerResponse)
           }
       }
   }
   
   ============================================ */
