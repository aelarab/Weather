//
//  ContentView.swift
//  Weather
//
//  Created by Abdelrahman Elaraby on 13/10/2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var vm: WeatherViewModel
    @EnvironmentObject var locationManager: LocationManager
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                content
                    .padding()
            }
            .onAppear {
                if let loc = locationManager.location {
                    vm.fetchWeather(location: loc)
                }
            }
            .onChange(of: locationManager.location) { newLocation in
                if let loc = newLocation {
                    vm.fetchWeather(location: loc)
                }
            }
        }
        
    }

    private var backgroundView: some View {
        Group {
            if isDaytime() {
                Image("day").resizable().ignoresSafeArea()
                
            } else {
                Image("night").resizable().ignoresSafeArea()
            }
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            topSection
            middleSection
            bottomSection
            Spacer()
        }
    }

    private var topSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(vm.locationName)
                .font(.title)
                .bold()
                .foregroundColor(foregroundColor())

            HStack(alignment: .center, spacing: 12) {
                if let url = vm.conditionIconURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: ProgressView()
                        case .success(let img): img.resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60)
                        case .failure: Image(systemName: "cloud")
                        @unknown default: EmptyView()
                        }
                    }
                }

                VStack(alignment: .leading) {
                    Text(vm.currentTemp).font(.system(size: 40)).bold().foregroundColor(foregroundColor())
                    Text(vm.conditionText).foregroundColor(foregroundColor())
                    HStack {
                        Text("H: \(vm.maxToday)")
                        Text("L: \(vm.minToday)")
                    }.foregroundColor(foregroundColor())
                }
            }
        }
    }

    private var middleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("3-DAY FORECAST")
                .font(.headline)
                .foregroundColor(foregroundColor())

            ForEach(vm.forecastDays.prefix(3)) { day in
                NavigationLink(destination: DetailsView(day: day)) {
                    HStack {
                        Text(dayTitle(from: day.date))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let icon = day.day.condition.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: icon.hasPrefix("http") ? icon : "https:\(icon)") {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30)
                            } placeholder: { ProgressView() }
                        }
                        Text(String(format: "%.0f - %.0f°C", day.day.mintemp_c, day.day.maxtemp_c))
                    }
                    .padding(.vertical, 8)
                    .foregroundColor(foregroundColor())
                }
            }
        }
        .padding()
        .background(Color.white.opacity(isDaytime() ? 0.6 : 0.12))
        .cornerRadius(12)
    }

    private var bottomSection: some View {
        VStack{
            Spacer()
            HStack(spacing: 12) {
                smallInfo(title: "Visibility", value: vm.visibility)
                Spacer()
                smallInfo(title: "Humidity", value: vm.humidity)
            }
            Spacer()
            HStack(spacing: 12) {
                smallInfo(title: "Feels Like", value: vm.feelsLike)
                Spacer()
                smallInfo(title: "Pressure", value: vm.pressure)
            }
            Spacer()
        }
    }

    private func smallInfo(title: String, value: String) -> some View {
        VStack {
            Text(title).font(.caption).foregroundColor(foregroundColor())
            Text(value).bold().foregroundColor(foregroundColor())
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white.opacity(isDaytime() ? 0.2 : 0.06))
        .cornerRadius(8)
    }

    private func isDaytime() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
    
    private func foregroundColor() -> Color {
        return isDaytime() ? .black : .white
    }

    private func dayTitle(from dateString: String) -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"; df.locale = Locale(identifier: "en_US_POSIX")
        if let d = df.date(from: dateString) {
            if Calendar.current.isDateInToday(d) { return "Today" }
            if Calendar.current.isDateInTomorrow(d) { return "Tomorrow" }
            let fmt = DateFormatter(); fmt.dateFormat = "EEEE"; return fmt.string(from: d)
        }
        return dateString
    }
}

