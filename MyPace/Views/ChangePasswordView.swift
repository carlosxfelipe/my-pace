//
//  ChangePasswordView.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 11/12/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    let authManager: AuthManager
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccess: Bool = false
    
    var isFormValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Senha Atual", text: $oldPassword)
                        .textContentType(.password)
                        .autocapitalization(.none)
                } header: {
                    Text("Senha Atual")
                }
                
                Section {
                    SecureField("Nova Senha", text: $newPassword)
                        .textContentType(.newPassword)
                        .autocapitalization(.none)
                    
                    SecureField("Confirmar Nova Senha", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .autocapitalization(.none)
                    
                    if !newPassword.isEmpty && newPassword.count < 6 {
                        Text("A senha deve ter no mínimo 6 caracteres")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    if !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword != confirmPassword {
                        Text("As senhas não coincidem")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Nova Senha")
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Button {
                        changePassword()
                    } label: {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("Alterar Senha")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Alterar Senha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Senha Alterada", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Sua senha foi alterada com sucesso.")
            }
        }
    }
    
    private func changePassword() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authManager.changePassword(
                    oldPassword: oldPassword,
                    newPassword: newPassword
                )
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                    
                    // Limpa os campos
                    oldPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                }
            } catch APIError.serverError(let message) {
                await MainActor.run {
                    isLoading = false
                    errorMessage = message
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Erro ao alterar senha. Tente novamente."
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView(authManager: AuthManager.shared)
}
