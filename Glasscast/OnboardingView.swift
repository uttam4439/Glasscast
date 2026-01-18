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
            GeometryReader { geo in
                Image("onboarding_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            .overlay(
                LinearGradient(
                    colors: [.black.opacity(0.2), .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )

            VStack {
                Spacer()

                VStack(spacing: 48) {
                    VStack(spacing: 16) {
                        Text("Your personal\nsky guide.")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Get hyper-local forecasts and severe\nweather alerts in real-time.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    // Pagination Dots
                    HStack(spacing: 8) {
                        Capsule().fill(Color.white).frame(width: 24, height: 6)
                        Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
                        Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 60)

                VStack(spacing: 20) {
                    Button {
                        appState.flow = .signup
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.0, green: 0.48, blue: 1.0)) // Vibrant Blue
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)

                    Button {
                        appState.flow = .signin
                    } label: {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 10)
            }
        }
    }
}




#Preview {
    OnboardingView()
}

