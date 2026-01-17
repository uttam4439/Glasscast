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
    @State private var isLoading = false
    @State private var goToHome = false

    var body: some View {
        VStack {

            Text("Create a password")
                .font(.largeTitle.bold())

            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button {
                setPassword()
            } label: {
                Text(isLoading ? "Setting..." : "Set Password")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(isPasswordValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .disabled(!isPasswordValid || isLoading)

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $goToHome) {
            ContentView()  // your app main screen
        }
    }

    private var isPasswordValid: Bool {
        password == confirmPassword &&
        password.range(
            of: #"^(?=.*\d)(?=.*[@$!%*?&]).{8,}$"#,
            options: .regularExpression
        ) != nil
    }

    private func setPassword() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await SupabaseKey.supaBase.auth.update(
                    user: UserAttributes(password: password)
                )

                // ✅ USER IS NOW FULLY SIGNED UP & LOGGED IN
                goToHome = true

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

