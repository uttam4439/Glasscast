//
//  OTPView.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI
import Supabase

struct OTPView: View {

    let email: String

    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?

    @State private var isVerifying = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {

            Text("STEP 2 OF 2")
                .foregroundColor(.gray)

            Text("Verify your email")
                .font(.system(size: 34, weight: .bold))
                .padding(.top, 6)

            Text("We’ve sent a 6-digit code to")
                .foregroundColor(.gray)

            Text(email)
                .fontWeight(.medium)

            // OTP Boxes (UNCHANGED)
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { i in
                    TextField("", text: $otp[i])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 44, height: 54)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .focused($focusedIndex, equals: i)
                        .onChange(of: otp[i]) { newValue in
                            if newValue.count > 1 {
                                otp[i] = String(newValue.last!)
                            }
                            if !newValue.isEmpty && i < 5 {
                                focusedIndex = i + 1
                            }
                        }
                }
            }
            .padding(.top, 20)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 6)
            }

            Button("Resend Code") {
                resendOTP()
            }
            .padding(.top, 12)

            Spacer()

            Button {
                verifyOTP()
            } label: {
                if isVerifying {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Verify")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(isOTPValid ? Color.blue : Color.gray)
            .clipShape(Capsule())
            .disabled(!isOTPValid || isVerifying)
        }
        .padding(.horizontal, 20)
        .onAppear {
            focusedIndex = 0
        }
    }

    // MARK: - OTP Validation
    private var isOTPValid: Bool {
        otp.joined().count == 6
    }

    private var otpString: String {
        otp.joined()
    }

    // MARK: - Verify OTP (Supabase)
    private func verifyOTP() {
        isVerifying = true
        errorMessage = nil

        Task {
            do {
                try await SupabaseKey.supaBase.auth.verifyOTP(
                    email: email,
                    token: otpString,
                    type: .signup
                )

                // ✅ OTP VERIFIED
                // Navigate to PasswordSetupView
                print("✅ OTP verified successfully")

            } catch {
                errorMessage = "Invalid OTP. Please try again."
                otp = Array(repeating: "", count: 6)
                focusedIndex = 0
            }

            isVerifying = false
        }
    }

    // MARK: - Resend OTP
    private func resendOTP() {
        Task {
            do {
                try await SupabaseKey.supaBase.auth.signInWithOTP(
                    email: email,
                    shouldCreateUser: true
                )
                otp = Array(repeating: "", count: 6)
                focusedIndex = 0
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
