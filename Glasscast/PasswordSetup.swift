//
//  PasswordSetup.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI
import Supabase

struct PasswordSetupView: View {

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {

            Text("Set your password")
                .font(.largeTitle.bold())

            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Create Account") {
                setPassword()
            }
            .disabled(!isPasswordValid)
        }
        .padding()
    }

    private var isPasswordValid: Bool {
        password == confirmPassword &&
        password.range(
            of: #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,15}$"#,
            options: .regularExpression
        ) != nil
    }

    private func setPassword() {
        Task {
            do {
                try await SupabaseKey.supaBase.auth.update(
                    user: UserAttributes(password: password)
                )
                print("✅ Account created")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    PasswordSetupView()
}

