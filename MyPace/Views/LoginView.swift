//
//  LoginView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 10/12/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let authManager: AuthManager
    let syncManager: SyncManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Login") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Senha", text: $password)
                        .textContentType(.password)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await performLogin()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isLoading ? "Entrando..." : "Entrar")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    
                    Button("Criar conta") {
                        showRegister = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView(authManager: authManager, syncManager: syncManager)
            }
        }
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.login(email: email, password: password)
            
            // Sincroniza dados após login bem-sucedido
            try await syncManager.syncFromAPI(
                modelContext: modelContext,
                authManager: authManager
            )
            
            dismiss()
        } catch APIError.unauthorized {
            errorMessage = "Email ou senha incorretos"
        } catch {
            errorMessage = "Erro ao fazer login: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let authManager: AuthManager
    let syncManager: SyncManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dados Pessoais") {
                    TextField("Nome", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Sobrenome", text: $lastName)
                        .textContentType(.familyName)
                }
                
                Section("Credenciais") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Senha", text: $password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirmar senha", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await performRegister()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isLoading ? "Criando..." : "Criar conta")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Criar Conta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !firstName.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func performRegister() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.register(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            
            // Faz upload das corridas locais após criar conta
            try await syncManager.uploadLocalRuns(
                modelContext: modelContext,
                authManager: authManager
            )
            
            dismiss()
        } catch {
            errorMessage = "Erro ao criar conta: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
