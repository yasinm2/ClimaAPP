//
//  File.swift
//  Clima
//
//  Created by Yasin Ağbulut on 23.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)

    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3c6f3f81d840aa4951bc9939ee2ead43&units=metric"
    
    var delegate :  WeatherManagerDelegate?
    func fetchWeather(cityName: String) {
        let URLstring = "\(weatherURL)&q=\(cityName)"
        performRequest(URLstring: URLstring)
        print(URLstring)
    }
    func fetchWeather (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let URLstring = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)" 
        performRequest(URLstring: URLstring)
    }

    func performRequest(URLstring: String) {
        if let url = URL(string: URLstring) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }

    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: name, temprature: temp)
            
            print(weather.tempratureString)
            
            
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }


    
    
    
    
}
