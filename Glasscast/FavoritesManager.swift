import SwiftUI
import Supabase
import Combine

class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteLocation] = []
    @Published var isLoading = false
    
    // Using the same client defined in DataController
    let client = SupabaseKey.supaBase
    
    @MainActor
    func fetchFavorites(userID: UUID?) async {
        guard let userID = userID else { return }
        isLoading = true
        do {
            let response: [FavoriteLocation] = try await client
                .from("favorite_cities")
                .select()
                .eq("user_id", value: userID)
                .execute()
                .value
            
            self.favorites = response
        } catch {
            print("Error fetching favorites: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func addFavorite(userID: UUID?, city: GeoCity) async {
        guard let userID = userID else { return }
        // limit 3
        guard favorites.count < 3 else { return }
        
        // Check duplicate
        if favorites.contains(where: { $0.city_name == city.name && $0.country == city.country }) {
            return
        }

        let newFav = FavoriteLocation(
            user_id: userID,
            city_name: city.name,
            country: city.country,
            lat: city.lat,
            lon: city.lon
        )
        
        do {
            try await client.from("favorite_cities").insert(newFav).execute()
            await fetchFavorites(userID: userID)
        } catch {
             print("Error adding favorite: \(error)")
        }
    }
    
    @MainActor
    func deleteFavorite(id: UUID, userID: UUID?) async {
        guard let userID = userID else { return }
        do {
            try await client.from("favorite_cities").delete().eq("id", value: id).execute()
            await fetchFavorites(userID: userID) // refresh
        } catch {
             print("Error deleting favorite: \(error)")
        }
    }
}
