//
//  RootView.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 18/01/26.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.flow {

        case .onboarding:
            OnboardingView()

        case .signup:
            SignupDetailsView()

        case .signin:
            SignInView()

        case .otp:
            OTPView(email: appState.signupEmail)

        case .password:
            PasswordSetupView()

        case .home:
            WeatherHomeView()   // 👈 YOUR HOME SCREEN
        }
    }
}
