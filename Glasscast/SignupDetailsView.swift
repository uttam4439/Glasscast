//
//  SignupDetailsView.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//


import SwiftUI
import Supabase

struct SignupDetailsView: View {

    @State private var fullName = ""
    @State private var email = ""
    @State private var location = "London, UK"

    @State private var isSendingOTP = false
    @State private var goToOTP = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {

            VStack(alignment: .leading, spacing: 12) {
                Text("STEP 1 OF 2")
                    .foregroundColor(.gray)

                Text("Tell us about\nyourself")
                    .font(.system(size: 34, weight: .bold))

                Text("Personalize your weather experience.")
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)

            VStack(spacing: 20) {

                TextField("John Doe", text: $fullName)
                    .textFieldStyle(.roundedBorder)

                TextField("example@email.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)

                TextField("London, UK", text: $location)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.top, 20)

            Spacer()

            Button {
                sendOTP()
            } label: {
                Text(isSendingOTP ? "Sending..." : "Next")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(isFormValid ? Color.blue : Color.gray)
            .clipShape(Capsule())
            .padding(.bottom, 16)
            .disabled(!isFormValid || isSendingOTP)
        }
        .padding(.horizontal, 20)
        .navigationDestination(isPresented: $goToOTP) {
            OTPView(email: email)
        }
    }

    private var isFormValid: Bool {
        !fullName.isEmpty &&
        email.hasSuffix("@gmail.com")
    }

    private func sendOTP() {
        isSendingOTP = true
        errorMessage = nil

        Task {
            do {
                try await SupabaseKey.supaBase.auth.signInWithOTP(
                    email: email,
                    shouldCreateUser: true
                )
                goToOTP = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isSendingOTP = false
        }
    }
}
