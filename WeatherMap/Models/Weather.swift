//
//  Weather.swift
//  WeatherMap
//
//  Created by ADMIN ODoYal on 18.05.2021.
//

import Foundation

struct Wether: Decodable {
    let main: String?
}

struct Temp: Decodable {
    let temp: Double?
}

struct CityWeather: Decodable {
    let name: String?
    let weather: [Wether]?
    let temp: Temp?
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case weather
        case temp = "main"
    }
}

protocol WeatherApiProtocol {
    func getHost(with cityName: String) -> String
    func getHost(lat:Double, lon: Double) -> String
}

struct WeatherApi: WeatherApiProtocol {
    private let apiKey: String = "c959d6dd933572783812cf5789210e6a"
//    let cityName: String?
//    let lon: Double?
//    let lat:Double?
    let startHost: String = "https://api.openweathermap.org/data/2.5/weather?"
    let endHost: String = "&units=metric"
    
    func getHost(with cityName: String) -> String {
        return startHost + "q=" + cityName + endHost + "&appid=" + apiKey
    }
    
    func getHost(lat: Double, lon: Double) -> String {
        return startHost + "lat="+String(lat )+"&lon="+String(lon )+endHost + "&appid=" + apiKey
    }
    
//    func getHost() -> String {
//        var cityAPI: String?
//        var latlongAPI: String?
//        if let city = cityName {
//            cityAPI = "q=\(city)"
//        } else if let lat = lat, let lon = lon{
//            latlongAPI = "lat="+String(lat )+"&lon="+String(lon)
//        }
//        return startHost + String(latlongAPI ?? "") + String(cityAPI ?? "")+endHost + "&appid=" + apiKey
//    }
}
