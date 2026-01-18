//
//  OTPView.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI
import Supabase

struct OTPView: View {
    @EnvironmentObject var appState: AppState
    let email: String

    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?

    @State private var isVerifying = false
    @State private var errorMessage: String?


    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.96, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom Navigation Bar Area
                HStack {
                    Button {
                        appState.flow = .signup
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(height: 44)

                // Progress
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Capsule().fill(Color.blue).frame(height: 4).frame(maxWidth: .infinity)
                        Capsule().fill(Color.blue).frame(height: 4).frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 40)
                    
                    Text("STEP 2 OF 2")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)

                // Content
                VStack(spacing: 16) {
                    Text("Verify your email")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 4) {
                        Text("We’ve sent a 6-digit code to")
                            .foregroundColor(.gray)
                        Text(email)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                // OTP Fields
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { i in
                        TextField("", text: $otp[i])
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.bold))
                            .frame(width: 48, height: 56)
                            .background(.regularMaterial)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedIndex == i ? Color.blue : Color.gray.opacity(0.1), lineWidth: 1.5)
                            )
                            .focused($focusedIndex, equals: i)
                            .onChange(of: otp[i]) { newValue in
                                if newValue.count > 1 {
                                    otp[i] = String(newValue.last!)
                                }
                                if !newValue.isEmpty {
                                    if i < 5 {
                                        focusedIndex = i + 1
                                    } else {
                                        focusedIndex = nil // dismiss keyboard after last digit? or keep focused
                                    }
                                } else if newValue.isEmpty && i > 0 {
                                    // Handle backspace logic roughly (SwiftUI quirk: empty state doesn't trigger change easily for backspace without custom binding, but this is acceptable for now)
                                    focusedIndex = i - 1
                                }
                            }
                    }
                }
                .padding(.top, 40)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 16)
                }

                Button("Resend Code") {
                    resendOTP()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.blue)
                .padding(.top, 24)

                Spacer()

                Button {
                    verifyOTP()
                } label: {
                    if isVerifying {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verify")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(otp.joined().count == 6 ? Color.blue : Color.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .disabled(otp.joined().count != 6 || isVerifying)

            }
        }
        .onAppear {
            focusedIndex = 0
        }
    }

    private func verifyOTP() {
        isVerifying = true
        errorMessage = nil
        let otpString = otp.joined()

        Task {
            do {
                try await SupabaseKey.supaBase.auth.verifyOTP(
                    email: email,
                    token: otpString,
                    type: .signup
                )
                // ✅ OTP VERIFIED → MOVE TO PASSWORD SETUP
                await MainActor.run {
                    appState.flow = .password
                }
            } catch {
                errorMessage = "Invalid OTP. Please try again."
                otp = Array(repeating: "", count: 6)
                focusedIndex = 0
            }
            isVerifying = false
        }
    }

    private func resendOTP() {
        Task {
            try? await SupabaseKey.supaBase.auth.signInWithOTP(email: email, shouldCreateUser: true)
        }
    }
}
