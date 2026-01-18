//
//  MessagePopUp.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 18/01/26.
//

import SwiftUI

struct EmailAlreadyExistsPopup: View {

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Blur background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 42))
                    .foregroundColor(.orange)

                Text("Email Already Registered")
                    .font(.system(size: 20, weight: .semibold))

                Text("This email is already associated with an account. Please sign in instead.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Go to Sign In") {
                    onDismiss()
                    // Later you can route to Sign In screen
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: true)
    }
}
