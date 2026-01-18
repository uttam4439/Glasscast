//
//  OnboardingView.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import Foundation
import SwiftUI
import Supabase

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Background Image
            Image("onboarding_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.1), .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Your personal\nsky guide.")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)

                    Text("Get hyper-local forecasts and severe\nweather alerts in real-time.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.bottom, 40)

                // Pagination Dots (Static for now as per image)
                HStack(spacing: 8) {
                    Capsule().fill(Color.white).frame(width: 24, height: 6)
                    Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
                    Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
                }
                .padding(.bottom, 40)

                Button {
                    appState.flow = .signup
                } label: {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.0, green: 0.48, blue: 1.0)) // Bright System Blue
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                Button {
                    // Sign In Action
                } label: {
                    Text("Sign In")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)
            }
            .padding(.bottom, 20)
        }
    }
}




#Preview {
    OnboardingView()
}

