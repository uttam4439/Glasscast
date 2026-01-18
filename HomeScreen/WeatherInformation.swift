//
//  WeatherInformation.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 18/01/26.
//

import SwiftUI
import MapKit
import Supabase

struct WeatherHomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State var forecast: ForecastResponseBody?
    @State private var showProfile = false
    @State private var isCelsius = true
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            if selectedTab == 0 {
                // MARK: - Home View
                ZStack {
                    // Background depending on weather?? For now keep gradient or make realistic
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.47, blue: 0.83),
                            Color(red: 0.10, green: 0.40, blue: 0.78)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Main Scrollable Content
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {
                                
                                // Spacer for Top Safe Area / Camera Notch
                                Color.clear.frame(height: 10)
                                
                                // MARK: - Top Bar
                                HStack {
                                    Button {
                                        withAnimation {
                                            isCelsius.toggle()
                                        }
                                    } label: {
                                        Text(isCelsius ? "°C" : "°F")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                    }
                                    Spacer()
                                    Button {
                                        showProfile = true
                                    } label: {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 24)) // Slightly larger for profile
                                    }
                                }
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.top, 40) // Extra padding for notch if safe area isn't enough
                                
                                if let weather = weather {
                                    // MARK: - City
                                    Text(weather.name)
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    // MARK: - Temperature
                                    VStack(spacing: 8) {
                                        Text("\(convert(weather.main.temp))°")
                                            .font(.system(size: 96, weight: .thin))
                                            .foregroundColor(.white)
                                        
                                        Text(weather.weather[0].main)
                                            .font(.system(size: 22))
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        Text("H:\(convert(weather.main.tempMax))°  L:\(convert(weather.main.tempMin))°")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    // MARK: - Forecast
                                    if let forecast = forecast {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("5-DAY FORECAST")
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(.horizontal, 24)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 16) {
                                                    ForEach(filterForecast(forecast.list)) { item in
                                                        ForecastCard(
                                                            day: getDayName(from: item.dt),
                                                            icon: mapIcon(item.weather.first?.icon ?? ""),
                                                            temp: "\(convert(item.main.tempMax))°",
                                                            low: "\(convert(item.main.tempMin))°"
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 24)
                                            }
                                        }
                                    }
                                    
                                    // MARK: - Details Grid
                                     VStack(alignment: .leading, spacing: 12) {
                                        Text("DETAILS")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.horizontal, 24)
                                        
                                        HStack(spacing: 20) {
                                            VStack(alignment: .leading) {
                                                Text("Humidity")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text("\(Int(weather.main.humidity))%")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text("Wind")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text("\(Int(weather.wind.speed)) m/s")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text("Feels Like")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text("\(convert(weather.main.feelsLike))°")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .padding(.horizontal, 24)

                                    }

                                     // MARK: - Weather Summary
                                    InfoCard {
                                        Text("Current conditions: \(weather.weather[0].description.capitalized). The pressure is \(Int(weather.main.pressure)) hPa.")
                                            .foregroundColor(.white.opacity(0.9))
                                            .font(.system(size: 16))
                                    }
                                    
                                } else {
                                    if locationManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .padding(.top, 100)
                                    } else {
                                        Button("Enable Location to see weather") {
                                            locationManager.requestLocation()
                                        }
                                        .padding(.top, 100)
                                        .foregroundColor(.white)
                                    }
                                }
                               
                                
                                // MARK: - Map Card
                                InfoCard {
                                    VStack(spacing: 16) {
                                        Map(coordinateRegion: .constant(
                                            MKCoordinateRegion(
                                                center: weather?.coord != nil ? CLLocationCoordinate2D(latitude: weather!.coord.lat, longitude: weather!.coord.lon) : CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                                                span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                                            )
                                        ))
                                        .frame(height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        
                                        Button {
                                            // open precipitation map
                                        } label: {
                                            Text("OPEN PRECIPITATION MAP")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Color.blue)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                
                                Spacer(minLength: 80) // Space for bottom bar
                            }
                        }
                        .refreshable {
                            locationManager.requestLocation()
                        }
                    }
                }
            } else {
                // MARK: - Search / Favorites View
                WeatherSearchView()
            }
            
            // MARK: - Bottom Bar (Fixed)
            VStack {
                Spacer()
                HStack(spacing: 64) {
                    Button {
                        withAnimation { selectedTab = 0 }
                    } label: {
                        Image(systemName: "map")
                            .symbolVariant(selectedTab == 0 ? .fill : .none)
                            .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.5))
                    }
                    
                    Button {
                        withAnimation { selectedTab = 1 }
                    } label: {
                        Image(systemName: "list.bullet")
                            .symbolVariant(selectedTab == 1 ? .circle.fill : .none) // Approximate fill
                            .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.5))
                    }
                }
                .font(.system(size: 24))
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .onAppear {
             if weather == nil && selectedTab == 0 {
                 locationManager.requestLocation()
             }
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                Task {
                    do {
                         weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                         forecast = try await weatherManager.getForecast(latitude: location.latitude, longitude: location.longitude)
                    } catch {
                        print("Error getting weather: \(error)")
                    }
                }
            }
        }
    }
    
    // Helper to convert temperature
    func convert(_ temp: Double) -> Int {
        if isCelsius {
            return Int(temp)
        } else {
            return Int(temp * 9/5 + 32)
        }
    }
    
    // Helper to filter forecast to get one per day (simplified)
    func filterForecast(_ list: [ForecastResponseBody.ForecastItem]) -> [ForecastResponseBody.ForecastItem] {
        // Just take every 8th item (24 hours / 3 hours = 8) to approximate daily info
        // Or better: Group by day and take noon
        // For simplicity in this demo:
        var daily: [ForecastResponseBody.ForecastItem] = []
        let calendar = Calendar.current
        var seenDays = Set<Int>()
        
        for item in list {
            let date = Date(timeIntervalSince1970: item.dt)
            let day = calendar.component(.day, from: date)
            if !seenDays.contains(day) {
                seenDays.insert(day)
                daily.append(item)
                if daily.count >= 5 { break }
            }
        }
        return daily
    }
    
    func getDayName(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue
        return formatter.string(from: date).uppercased()
    }
    
    func mapIcon(_ icon: String) -> String {
        // Simple mapping from OpenWeatherMap icon codes to SF Symbols
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d", "03d": return "cloud.sun.fill"
        case "02n", "03n": return "cloud.moon.fill"
        case "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snowflake"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    struct ForecastCard: View {
        let day: String
        let icon: String
        let temp: String
        let low: String
        
        var body: some View {
            VStack(spacing: 12) {
                Text(day)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.yellow)
                
                Text(temp)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                
                Text(low)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 110, height: 150)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }
    
    struct InfoCard<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            content
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)
        }
    }
    
    struct ProfileView: View {
        @EnvironmentObject var appState: AppState
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color(red: 0.94, green: 0.96, blue: 0.99).ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        
                        VStack(spacing: 16) {
                            ProfileDetailRow(icon: "person.fill", title: "Name", value: appState.fullName)
                            ProfileDetailRow(icon: "envelope.fill", title: "Email", value: appState.signupEmail)
                            ProfileDetailRow(icon: "mappin.and.ellipse", title: "Location", value: appState.location)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        
                        Button {
                            Task {
                                try? await SupabaseKey.supaBase.auth.signOut()
                                await MainActor.run {
                                    appState.flow = .onboarding
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct ProfileDetailRow: View {
        let icon: String
        let title: String
        let value: String
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(value.isEmpty ? "Not available" : value)
                        .font(.body)
                        .fontWeight(.medium)
                }
                Spacer()
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}
