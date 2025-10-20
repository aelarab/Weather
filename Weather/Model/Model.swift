//
//  Model.swift
//  Weather
//
//  Created by Abdelrahman Elaraby on 13/10/2025.
//

import Foundation

enum Secrets {
    static let weatherAPIKey = "85c7a5d2bf714a168a1200201251310"
}

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let region: String?
    let country: String?
    let localtime_epoch: Int
    let localtime: String
}

struct Current: Codable {
    let temp_c: Double
    let condition: Condition
    let feelslike_c: Double
    let vis_km: Double
    let humidity: Int
    let pressure_mb: Double
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var id: String { date }
    let date: String
    let day: Day
    let hour: [Hour]
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let condition: Condition
}

struct Hour: Codable, Identifiable {
    var id: Int { time_epoch }
    let time_epoch: Int
    let time: String
    let temp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
}

extension Date {
    static func from(weatherAPITimeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: weatherAPITimeString)
    }

    func hourString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h a"
        fmt.locale = Locale.current
        return fmt.string(from: self)
    }
}
