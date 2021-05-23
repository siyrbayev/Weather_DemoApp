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

struct Sys: Decodable {
    let country: String?
    let sunriseUnixDateTime: Int?
    let sunsetUnixDateTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case country
        case sunriseUnixDateTime = "sunrise"
        case sunsetUnixDateTime = "sunset"
    }
}

struct CityWeather: Decodable {
    let name: String?
    let weather: [Wether]?
    let temp: Temp?
    let sys: Sys?
    let currentUnixDateTime: Int?
    let timezoneSeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case weather
        case temp = "main"
        case sys = "sys"
        case currentUnixDateTime = "dt"
        case timezoneSeconds = "timezone"
    }
}

enum WeatherTypes: String {
    case Clouds,Rain,Clear,Snow
    case Error
}

enum DayParts: String {
    case Day,Night
    case Eror
}

protocol WeatherApiProtocol {
    func getHost(with cityName: String) -> String
    func getHost(lat:Double, lon: Double) -> String
}

struct WeatherApi: WeatherApiProtocol {
    private let apiKey: String = "c959d6dd933572783812cf5789210e6a"
    let startHost: String = "https://api.openweathermap.org/data/2.5/weather?"
    let endHost: String = "&units=metric"
    
    func getHost(with cityName: String) -> String {
        return startHost + "q=" + cityName + endHost + "&appid=" + apiKey
    }
    
    func getHost(lat: Double, lon: Double) -> String {
        return startHost + "lat="+String(lat )+"&lon="+String(lon )+endHost + "&appid=" + apiKey
    }
}
