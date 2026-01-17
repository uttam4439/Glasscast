//
//  DataStruct.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import Foundation

struct SignupOTPModel: Codable, Identifiable {
    let id = UUID()

    var fullName: String
    var email: String
    var location: String

    var otpVerified: Bool = false
}


