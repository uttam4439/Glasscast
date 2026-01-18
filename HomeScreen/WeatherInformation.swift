//
//  WeatherInformation.swift
//  Glasscast
//
//  Created by UTTAM KUMAR on 18/01/26.
//

import SwiftUI
import MapKit

struct WeatherHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showProfile = false
    
    var body: some View {
        ZStack {
            // Background
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
                            Image(systemName: "line.3.horizontal")
                            Spacer()
                            Image(systemName: "arrow.clockwise")
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
                        
                        // MARK: - City
                        Text("New York")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                        
                        // MARK: - Temperature
                        VStack(spacing: 8) {
                            Text("72°")
                                .font(.system(size: 96, weight: .thin))
                                .foregroundColor(.white)
                            
                            Text("Partly Cloudy")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("H:78°  L:64°")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // MARK: - Forecast
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5-DAY FORECAST")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForecastCard(day: "MON", icon: "cloud.sun.fill", temp: "75°", low: "62°")
                                    ForecastCard(day: "TUE", icon: "cloud.rain.fill", temp: "68°", low: "58°")
                                    ForecastCard(day: "WED", icon: "sun.max.fill", temp: "80°", low: "65°")
                                    ForecastCard(day: "THU", icon: "cloud.bolt.fill", temp: "73°", low: "60°")
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // MARK: - Weather Summary
                        InfoCard {
                            Text("Expect scattered clouds today with a light breeze from the East. Temperatures will remain mild through the evening.")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 16))
                        }
                        
                        // MARK: - Map Card
                        InfoCard {
                            VStack(spacing: 16) {
                                Map(coordinateRegion: .constant(
                                    MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
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
                
                // MARK: - Bottom Bar (Fixed)
                HStack {
                    Image(systemName: "map")
                    Spacer()
                    Circle()
                        .frame(width: 8, height: 8)
                    Spacer()
                    Image(systemName: "list.bullet")
                }
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 48)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
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
