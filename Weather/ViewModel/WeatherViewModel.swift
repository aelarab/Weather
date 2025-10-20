//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Abdelrahman Elaraby on 13/10/2025.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
final class WeatherViewModel: ObservableObject {
    @Published var locationName: String = "-"
    @Published var currentTemp: String = "-"
    @Published var conditionText: String = "-"
    @Published var maxToday: String = "-"
    @Published var minToday: String = "-"
    @Published var conditionIconURL: URL?
    @Published var forecastDays: [ForecastDay] = []
    @Published var hourlyForSelectedDay: [Hour] = []

    @Published var visibility: String = "-"
    @Published var humidity: String = "-"
    @Published var feelsLike: String = "-"
    @Published var pressure: String = "-"

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchWeather()
    }

    func fetchWeather(location: CLLocation? = nil) {
        isLoading = true
        errorMessage = nil

        let lat = location?.coordinate.latitude ?? 31.4175
        let lon = location?.coordinate.longitude ?? 31.8144

        WeatherService.shared.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let resp):
                    self.apply(response: resp)
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
    private func apply(response: WeatherResponse) {
        locationName = response.location.name
        currentTemp = String(format: "%.0f°C", response.current.temp_c)
        conditionText = response.current.condition.text
        feelsLike = String(format: "%.0f°C", response.current.feelslike_c)
        visibility = String(format: "%.1f km", response.current.vis_km)
        humidity = "\(response.current.humidity) %"
        pressure = String(format: "%.0f mb", response.current.pressure_mb)

        if let first = response.forecast.forecastday.first {
            maxToday = String(format: "%.0f°C", first.day.maxtemp_c)
            minToday = String(format: "%.0f°C", first.day.mintemp_c)
        }

        if let iconString = response.current.condition.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: iconString.hasPrefix("http") ? iconString : "https:\(iconString)"){
            conditionIconURL = url
        } else {
            conditionIconURL = nil
        }

        forecastDays = response.forecast.forecastday
    }

    func selectForecastDay(_ day: ForecastDay) {
        hourlyForSelectedDay = day.hour
    }
}

