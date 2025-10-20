//
//  WeatherApp.swift
//  Weather
//
//  Created by Abdelrahman Elaraby on 13/10/2025.
//

import SwiftUI

@main
struct WeatherApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherVM = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(weatherVM)
                .environmentObject(locationManager)
        }
    }
}
