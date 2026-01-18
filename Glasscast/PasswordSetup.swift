//
//  PasswordSetup.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI
import Supabase

struct PasswordSetupView: View {
    @EnvironmentObject var appState: AppState

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.96, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Create Password")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Secure your account with a strong password.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PASSWORD")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        SecureField("Minimum 8 characters", text: $password)
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("CONFIRM PASSWORD")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        SecureField("Must match password", text: $confirmPassword)
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 20)
                }

                Spacer()

                Button {
                    setPassword()
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Create Account")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isPasswordValid ? Color.blue : Color.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .disabled(!isPasswordValid || isLoading)
            }
        }
    }

    private var isPasswordValid: Bool {
        password == confirmPassword && password.count >= 6 // Simplified for demo, can add complex regex
    }

    private func setPassword() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let user = try await SupabaseKey.supaBase.auth.update(
                    user: UserAttributes(password: password)
                )

                // ✅ Insert into profiles table
                let profile = UserProfile(
                    id: user.id,
                    full_name: appState.fullName,
                    email: appState.signupEmail,
                    location: appState.location
                )
                
                try await SupabaseKey.supaBase
                    .from("profiles")
                    .insert(profile)
                    .execute()

                // ✅ USER IS NOW FULLY SIGNED UP & LOGGED IN
                await MainActor.run {
                    appState.userID = user.id
                    appState.flow = .home
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}


#Preview {
    PasswordSetupView()
}

