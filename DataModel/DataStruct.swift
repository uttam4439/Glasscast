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

extension ResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}

// Model for 5-Day Forecast
struct ForecastResponseBody: Decodable {
    var list: [ForecastItem]
    var city: CityResponse
    
    struct CityResponse: Decodable {
        var name: String
        var country: String
    }
    
    struct ForecastItem: Decodable, Identifiable {
        let id = UUID()
        var dt: Double
        var main: ResponseBody.MainResponse
        var weather: [ResponseBody.WeatherResponse]
        var dt_txt: String
        var sys: SysResponse

        struct SysResponse: Decodable {
            var pod: String
        }

        enum CodingKeys: String, CodingKey {
            case dt, main, weather, dt_txt, sys
        }
    }
}
