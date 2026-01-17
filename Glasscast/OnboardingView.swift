//
//  OnboardingView.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import SwiftUI

struct OnboardingView: View {

    var body: some View {
        ZStack {

            Image("onboarding_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // MARK: - Text Content
                VStack(spacing: 12) {

                    Text("Your personal\nsky guide")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Hyper-local forecasts and real-time severe weather alerts — beautifully minimal.")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 320)
                }

                Spacer(minLength: 36)

                // MARK: - Page Indicator
                HStack(spacing: 6) {
                    Capsule()
                        .frame(width: 18, height: 4)
                        .foregroundStyle(.white)

                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundStyle(.white.opacity(0.5))

                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer(minLength: 28)

                // MARK: - Get Started (BLUE ROUNDED)
                NavigationLink {
                    SignupDetailsView()
                } label: {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(Color.blue)
                .clipShape(Capsule())
                .padding(.horizontal, 20)

                Button("Sign In") {
                    // Sign in
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 10)

                Spacer(minLength: 20)
            }
        }
    }
}


#Preview {
    OnboardingView()
}

