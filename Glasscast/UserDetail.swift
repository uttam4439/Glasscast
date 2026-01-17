//
//  UserDetail.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI

struct SignupDetailsView: View {

    // MARK: - State
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            // Header
            VStack(spacing: 8) {
                Text("Create your account")
                    .font(.system(size: 28, weight: .bold))

                Text("All details must be valid to continue")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)

            // Form
            VStack(spacing: 16) {

                inputField(
                    title: "Full Name",
                    placeholder: "Enter your name",
                    text: $fullName
                )

                inputField(
                    title: "Email (Gmail only)",
                    placeholder: "example@gmail.com",
                    text: $email,
                    keyboard: .emailAddress
                )

                if !email.isEmpty && !isValidGmail(email) {
                    validationText("Email must end with @gmail.com")
                }

                secureField(
                    title: "Password",
                    placeholder: "Create a password",
                    text: $password
                )

                passwordRules(password)

                secureField(
                    title: "Confirm Password",
                    placeholder: "Re-enter password",
                    text: $confirmPassword
                )

                if !confirmPassword.isEmpty && password != confirmPassword {
                    validationText("Passwords do not match")
                }
            }

            Spacer()

            // Sign Up Button
            Button(action: {
                print("Signup successful")
            }) {
                Text("Sign Up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(isFormValid ? Color.blue : Color.gray)
            .clipShape(Capsule())
            .padding(.horizontal, 10)
            .disabled(!isFormValid)

            Spacer(minLength: 10)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Form Valid
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        isValidGmail(email) &&
        isValidPassword(password) &&
        password == confirmPassword
    }

    // MARK: - Validation Functions
    private func isValidGmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@gmail\.com$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let regex =
        #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,15}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    // MARK: - UI Components

    private func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func secureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            SecureField(placeholder, text: text)
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func validationText(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(.red)
    }

    private func passwordRules(_ password: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            rule("8–15 characters", password.count >= 8 && password.count <= 15)
            rule("1 uppercase letter", password.range(of: "[A-Z]", options: .regularExpression) != nil)
            rule("1 lowercase letter", password.range(of: "[a-z]", options: .regularExpression) != nil)
            rule("1 number", password.range(of: "[0-9]", options: .regularExpression) != nil)
            rule("1 special character", password.range(of: "[@$!%*?&]", options: .regularExpression) != nil)
        }
    }

    private func rule(_ text: String, _ valid: Bool) -> some View {
        HStack {
            Image(systemName: valid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(valid ? .green : .gray)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SignupDetailsView()
}
