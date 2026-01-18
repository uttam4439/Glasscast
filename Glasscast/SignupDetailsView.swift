import SwiftUI
import Supabase

struct SignupDetailsView: View {
    @EnvironmentObject var appState: AppState

    @State private var fullName = ""
    @State private var email = ""
    @State private var location = ""

    @State private var isSendingOTP = false
    @State private var errorMessage: String?
    
    @State private var showEmailExistsPopup = false

    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func sendOTP() {
        isSendingOTP = true
        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        Task {
            do {
                // 1. Check if email exists in profiles table
                let response: [UserProfile] = try await SupabaseKey.supaBase
                    .from("profiles")
                    .select()
                    .eq("email", value: trimmedEmail)
                    .execute()
                    .value
                
                if !response.isEmpty {
                    // Email exists! Show popup
                    await MainActor.run {
                        showEmailExistsPopup = true
                        isSendingOTP = false
                    }
                    return
                }
                
                // 2. If not found, proceed to send magic link
                try await SupabaseKey.supaBase.auth.signInWithOTP(
                    email: trimmedEmail,
                    shouldCreateUser: true
                )
                
                await MainActor.run {
                    appState.updateSession(
                        email: trimmedEmail,
                        fullName: fullName,
                        location: location,
                        next: .otp
                    )
                }
            } catch {
                print("Signup error: \(error)")
                await MainActor.run {
                    errorMessage = "Something went wrong. Please try again."
                }
            }
            isSendingOTP = false
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.96, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                
                // Top Custom Navigation Bar Area
                HStack {
                    Button {
                        appState.flow = .onboarding
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(height: 44)

                // Progress Bar
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Capsule()
                            .fill(Color.blue)
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 40)
                    
                    Text("STEP 1 OF 2")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tell us about\nyourself")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Personalize your weather experience.")
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 16)

                        // Fields
                        VStack(alignment: .leading, spacing: 20) {
                            
                            InputGroup(title: "FULL NAME", placeholder: "John Doe", text: $fullName)
                            
                            InputGroup(title: "EMAIL ADDRESS", placeholder: "example@email.com", text: $email, keyboardType: .emailAddress)
                            
                            InputGroup(title: "PRIMARY LOCATION", placeholder: "London, UK", text: $location)
                            
                            if let errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, -10)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Bottom Button
                Button {
                    sendOTP()
                } label: {
                    if isSendingOTP {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    } else {
                        Text("Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .background(isFormValid ? Color.blue : Color.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .disabled(!isFormValid || isSendingOTP)
            }
        }
        .overlay {
            if showEmailExistsPopup {
                EmailAlreadyExistsPopup {
                    showEmailExistsPopup = false
                }
            }
        }
    }
}

// Helper View for Inputs
struct InputGroup: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
    }
}


