import Foundation
import CoreLocation

class WeatherManager {
    // API Key provided by user
    private let apiKey = "c8dc3c6835e66ffaa90c373ccaf8e4d5"
    
    // HTTP request to get the current weather depending on the coordinates
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else {
            fatalError("Missing URL")
        }

        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error while fetching data")
        }
        
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        
        return decodedData
    }

    // HTTP request to get the 5-day forecast
    func getForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ForecastResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else {
            fatalError("Missing URL")
        }

        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error while fetching data")
        }
        
        let decodedData = try JSONDecoder().decode(ForecastResponseBody.self, from: data)
        
        return decodedData
    }
    }
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
