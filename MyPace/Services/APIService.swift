//
//  APIService.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 10/12/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://mypace-backend.onrender.com"
    
    private init() {}
    
    // MARK: - Authentication
    
    struct LoginRequest: Codable {
        let email: String
        let password: String
    }
    
    struct RegisterRequest: Codable {
        let email: String
        let password: String
        let passwordConfirm: String
        let firstName: String
        let lastName: String
        
        enum CodingKeys: String, CodingKey {
            case email, password
            case passwordConfirm = "password_confirm"
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
    
    struct AuthResponse: Codable {
        let token: String
        let email: String?
        let firstName: String?
        let lastName: String?
        
        enum CodingKeys: String, CodingKey {
            case token, email
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
    
    func login(email: String, password: String) async throws -> String {
        let url = URL(string: "\(baseURL)/api/auth/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return authResponse.token
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws -> String {
        let url = URL(string: "\(baseURL)/api/auth/register/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RegisterRequest(
            email: email,
            password: password,
            passwordConfirm: password,
            firstName: firstName,
            lastName: lastName
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.serverError("Erro ao criar conta")
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return authResponse.token
    }
    
    // MARK: - Runs API
    
    struct APIRun: Codable {
        let id: UUID
        let date: Date
        let distanceKm: String
        let timeMinutes: String
        let pace: Double
        
        enum CodingKeys: String, CodingKey {
            case id, date, pace
            case distanceKm = "distance_km"
            case timeMinutes = "time_minutes"
        }
    }
    
    struct RunListResponse: Codable {
        let count: Int
        let results: [APIRun]
    }
    
    func fetchRuns(token: String) async throws -> [APIRun] {
        let url = URL(string: "\(baseURL)/api/runs/")!
        var request = URLRequest(url: url)
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.unauthorized
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let listResponse = try decoder.decode(RunListResponse.self, from: data)
        return listResponse.results
    }
    
    func createRun(token: String, date: Date, distanceKm: Double, timeMinutes: Double) async throws -> APIRun {
        let url = URL(string: "\(baseURL)/api/runs/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "date": ISO8601DateFormatter().string(from: date),
            "distance_km": distanceKm,
            "time_minutes": timeMinutes
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.serverError("Erro ao criar corrida")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(APIRun.self, from: data)
    }
    
    func deleteRun(token: String, runId: UUID) async throws {
        let url = URL(string: "\(baseURL)/api/runs/\(runId.uuidString)/")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
            throw APIError.serverError("Erro ao deletar corrida")
        }
    }
}
