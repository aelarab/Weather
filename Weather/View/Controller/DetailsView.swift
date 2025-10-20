//
//  DetailsView.swift
//  Weather
//
//  Created by Abdelrahman Elaraby on 13/10/2025.
//

import SwiftUI

struct DetailsView: View {
    let day: ForecastDay
    @EnvironmentObject var vm: WeatherViewModel

    var body: some View {
        ZStack {
            backgroundView
            list
        }
        .navigationTitle(dayTitle(from: day.date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarColorScheme(isDaytime() ? .light : .dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Text("")
                        .foregroundColor(foregroundColor())
                }
                .onTapGesture {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = windowScene.windows.first?.rootViewController {
                        root.dismiss(animated: true)
                    }
                }
            }
        }
    }
    private var backgroundView: some View {
            if isDaytime() {
                Image("day").resizable().ignoresSafeArea()
            } else {
                Image("night").resizable().ignoresSafeArea()
            }
    }
    
    private var list: some View {
        List {
            Section(header: Text("Hourly").foregroundColor(foregroundColor())) {
                ForEach(day.hour) { h in
                    HStack {
                        Text(hourLabel(from: h.time))
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(foregroundColor())
                        Spacer()
                        if let icon = h.condition.icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: icon.hasPrefix("http") ? icon : "https:\(icon)") {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        Spacer()
                        Text(String(format: "%.0f°C", h.temp_c)).foregroundColor(foregroundColor())
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .headerProminence(.increased)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
    
    private func isDaytime() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
    
    private func foregroundColor() -> Color {
        return isDaytime() ? .black : .white
    }
    
    private func hourLabel(from timeString: String) -> String {
        if let d = Date.from(weatherAPITimeString: timeString) { return d.hourString() }
        return timeString
    }

    private func dayTitle(from dateString: String) -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"; df.locale = Locale(identifier: "en_US_POSIX")
        if let d = df.date(from: dateString) {
            let fmt = DateFormatter(); fmt.dateFormat = "EEEE, MMM d"; return fmt.string(from: d)
        }
        return dateString
    }
}
