import SwiftUI
import Supabase

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Using the simplified SupabaseKey wrapper
    private let client = SupabaseKey.supaBase
    
    var body: some View {
        ZStack {
            // Light Background
            Color(red: 0.77, green: 0.87, blue: 0.96) // Light blueish gray from image
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
                
                // Content
                VStack(alignment: .leading, spacing: 32) {
                    
                    Text("Welcome Back")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    // Form Container
                    VStack(spacing: 0) {
                        // Email Field
                        HStack {
                            Text("Email")
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .frame(width: 80, alignment: .leading)
                            
                            TextField("example@icloud.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.white)
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Password Field
                        HStack {
                            Text("Password")
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .frame(width: 80, alignment: .leading)
                            
                            SecureField("••••••••••••", text: $password)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            // Handle forgot password
                        }
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Sign In Button
                    Button {
                        signIn()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        } else {
                            Text("Sign In")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                    }
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    // Create Account Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Button("Create one") {
                            appState.flow = .signup
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let session = try await client.auth.signIn(email: email, password: password)
                
                // Fetch profile
                let profile: UserProfile = try await client
                    .from("profiles")
                    .select()
                    .eq("id", value: session.user.id)
                    .single()
                    .execute()
                    .value
                
                await MainActor.run {
                    appState.signupEmail = profile.email ?? session.user.email ?? email
                    appState.fullName = profile.full_name ?? ""
                    appState.location = profile.location ?? ""
                    appState.userID = session.user.id
                    appState.flow = .home
                }
            } catch {
                print("Sign in/Profile error: \(error)")
                await MainActor.run {
                    errorMessage = "Invalid email or password."
                }
            }
            isLoading = false
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AppState())
}
