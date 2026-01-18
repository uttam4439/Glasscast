//
//  AppSatate.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 18/01/26.
//

import SwiftUI
import Combine

enum AppFlow {
    case onboarding
    case signup
    case otp
    case password
    case home
}

final class AppState: ObservableObject {
    @Published var flow: AppFlow = .onboarding
    @Published var signupEmail: String = ""
    @Published var fullName: String = ""
    @Published var location: String = ""

    func updateSession(email: String, fullName: String, location: String, next: AppFlow) {
        self.signupEmail = email
        self.fullName = fullName
        self.location = location
        self.flow = next
    }
}
