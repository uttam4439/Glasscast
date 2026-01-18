//
//  DataStruct.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 17/01/26.
//

import Foundation

struct SignupOTPModel: Codable, Identifiable {
    let id : UUID

    var fullName: String
    var email: String
    var location: String

    var otpVerified: Bool = false
}

// Model for Current Weather
struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
    var sys: SysResponse

    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }

    struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
    
    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
    
    struct SysResponse: Decodable {
        var country: String
        var sunrise: Int
        var sunset: Int
    }
}
