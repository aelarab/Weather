//
//  WeatherService.swift
//  Weather
//
//  Created by Abdelrahman Elaraby on 13/10/2025.
//

import Foundation

enum WeatherError: Error, LocalizedError {
    case missingAPIKey
    case requestFailed
    case decodingFailed
    case other(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "API key is missing. Put it in Secrets.swift"
        case .requestFailed: return "Network request failed."
        case .decodingFailed: return "Failed to decode server response."
        case .other(let e): return e.localizedDescription
        }
    }
}

final class WeatherService {
    static let shared = WeatherService()
    private init() {}

    func fetchWeather(lat: Double ,lon: Double ,days: Int = 3, completion: @escaping (Result<WeatherResponse, WeatherError>) -> Void) {
        guard !Secrets.weatherAPIKey.isEmpty else {
            completion(.failure(.missingAPIKey))
            return
        }
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(Secrets.weatherAPIKey)&q=\(lat),\(lon)&days=\(days)&aqi=yes&alerts=no"
        guard let url = URL(string: urlString) else { completion(.failure(.requestFailed)); return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let e = error { completion(.failure(.other(e))); return }
            guard let data = data else { completion(.failure(.requestFailed)); return }
            do {
                let decoder = JSONDecoder()
                let resp = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(resp))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }
        task.resume()
    }
}
