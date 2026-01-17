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
    var body: some View {
        NavigationStack {
            ZStack {
                Image("onboarding_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    Text("Your personal\nsky guide.")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Get hyper-local forecasts and severe\nweather alerts in real-time.")
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    Spacer()

                    NavigationLink {
                        SignupDetailsView()
                    } label: {
                        Text("Get Started")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .padding(.horizontal, 24)
                    }

                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding(.top, 14)

                    Spacer(minLength: 20)
                }
            }
        }
    }
}




#Preview {
    OnboardingView()
}

