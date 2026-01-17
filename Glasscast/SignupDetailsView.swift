import SwiftUI
import Supabase

struct SignupDetailsView: View {
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var location = "London, UK"
    
    @State private var isSendingOTP = false
    @State private var goToOTP = false
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func sendOTP() {
        isSendingOTP = true
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter your full name."
            isSendingOTP = false
            return
        }
        
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            isSendingOTP = false
            return
        }
        
        guard !trimmedLocation.isEmpty else {
            errorMessage = "Please enter your primary location."
            isSendingOTP = false
            return
        }
        
        // ✅ REAL SUPABASE OTP CALL
        Task {
            do {
                try await SupabaseKey.supaBase.auth.signInWithOTP(
                    email: trimmedEmail,
                    shouldCreateUser: true
                )
                
                // ✅ Navigate ONLY after OTP is sent
                goToOTP = true
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isSendingOTP = false
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.95, green: 0.98, blue: 1.0),
                Color(red: 0.90, green: 0.96, blue: 1.0)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 24)
                
                // Card container
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("STEP 1 OF 2")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Tell us about\nyourself")
                            .font(.system(size: 34, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Personalize your weather experience.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Form fields
                    VStack(alignment: .leading, spacing: 16) {
                        // Full name
                        Text("FULL NAME")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                        TextField("John Doe", text: $fullName)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        // Email
                        Text("EMAIL ADDRESS")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                        TextField("example@email.com", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        // Location
                        Text("PRIMARY LOCATION")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                        HStack(spacing: 8) {
                            TextField("London, UK", text: $location)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            
                            Button(action: {}) {
                                Image(systemName: "location")
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    // Primary action
                    Button {
                        sendOTP()
                    } label: {
                        Text(isSendingOTP ? "Sending..." : "Next")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundColor(.white)
                    }
                    .background(isFormValid ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .disabled(!isFormValid || isSendingOTP)
                }
                .padding(24)
                .frame(maxWidth: 600)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.6))
                        .background(.thinMaterial)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                
                Spacer(minLength: 24)
            }
        }
        .navigationDestination(isPresented: $goToOTP) {
            OTPView(email: email)
        }
    }
}

