//
//  AuthManager.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 10/12/25.
//

import Foundation
import SwiftUI

@Observable
class AuthManager {
    static let shared = AuthManager()
    
    private let tokenKey = "auth_token"
    private let emailKey = "user_email"
    
    var isLoggedIn: Bool {
        token != nil
    }
    
    var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    var userEmail: String? {
        didSet {
            if let email = userEmail {
                UserDefaults.standard.set(email, forKey: emailKey)
            } else {
                UserDefaults.standard.removeObject(forKey: emailKey)
            }
        }
    }
    
    private init() {
        // Carrega token salvo
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        self.userEmail = UserDefaults.standard.string(forKey: emailKey)
    }
    
    func login(email: String, password: String) async throws {
        let token = try await APIService.shared.login(email: email, password: password)
        self.token = token
        self.userEmail = email
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        let token = try await APIService.shared.register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        self.token = token
        self.userEmail = email
    }
    
    func logout() {
        self.token = nil
        self.userEmail = nil
    }
}
