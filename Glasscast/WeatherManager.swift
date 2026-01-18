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

