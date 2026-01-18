import SwiftUI
import CoreLocation

struct WeatherSearchView: View {
    @StateObject var favoritesManager = FavoritesManager()
    @EnvironmentObject var appState: AppState // To get email
    @State private var searchText = ""
    @State private var searchResults: [GeoCity] = []
    @State private var isSearching = false
    
    // For debouncing search
    @State private var searchTask: Task<Void, Never>?
    
    var weatherManager = WeatherManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.47, blue: 0.83),
                        Color(red: 0.10, green: 0.40, blue: 0.78)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // Custom Header
                    Text("Weather")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        TextField("Search for a city or airport", text: $searchText)
                            .foregroundColor(.white)
                            .onChange(of: searchText) { newValue in
                                performSearch(query: newValue)
                            }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    if !searchResults.isEmpty {
                        // Search Results List
                        List(searchResults) { city in
                            Button {
                                addToFavorites(city: city)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(city.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("\(city.state ?? ""), \(city.country)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    } else {
                        // Favorites List
                        if !favoritesManager.favorites.isEmpty {
                            Text("MY LOCATIONS")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(favoritesManager.favorites) { fav in
                                        FavoriteWeatherCard(favorite: fav, manager: favoritesManager)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                             Spacer()
                             if favoritesManager.isLoading {
                                 ProgressView()
                             } else {
                                Text("No favorites added.")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding()
                             }
                             Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await favoritesManager.fetchFavorites(userID: appState.userID)
            }
        }
    }
    
    func performSearch(query: String) {
        searchTask?.cancel()
        if query.count < 3 {
            searchResults = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            do {
                let results = try await weatherManager.searchCity(query: query)
                await MainActor.run {
                    self.searchResults = results
                }
            } catch is CancellationError {
                // Ignore cancellation
            } catch {
                if (error as NSError).code == NSURLErrorCancelled { return }
                print("Search error: \(error)")
            }
        }
    }
    
    func addToFavorites(city: GeoCity) {
        Task {
            await favoritesManager.addFavorite(userID: appState.userID, city: city)
            await MainActor.run {
                searchText = ""
                searchResults = []
            }
        }
    }
}

struct FavoriteWeatherCard: View {
    let favorite: FavoriteLocation
    @ObservedObject var manager: FavoritesManager
    @EnvironmentObject var appState: AppState
    
    @State private var weather: ResponseBody?
    let weatherManager = WeatherManager()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(weather?.name ?? favorite.name)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                if let weather = weather {
                    Text(weather.weather.first?.main ?? "")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(getCurrentTime(timezoneOffset: weather.sys.sunrise)) // Fixed timezone logic would go here
                         .font(.caption)
                         .foregroundColor(.white.opacity(0.6))
                } else {
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            if let weather = weather {
                VStack(alignment: .trailing) {
                    Text("\(Int(weather.main.temp))°")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.white)
                    
                    Text("H:\(Int(weather.main.tempMax))° L:\(Int(weather.main.tempMin))°")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(height: 120)
        .contextMenu {
            Button(role: .destructive) {
                Task {
                    await manager.deleteFavorite(id: favorite.id, userID: appState.userID)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .task {
            do {
                weather = try await weatherManager.getCurrentWeather(latitude: favorite.latitude, longitude: favorite.longitude)
            } catch {
                print("Failed to load weather for card")
            }
        }
    }
    
    func getCurrentTime(timezoneOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
