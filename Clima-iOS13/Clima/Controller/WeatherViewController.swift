import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    
}

extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchButton(_ sender: UIButton) {
        searchTextField.endEditing(true)
        
        if let searchText = searchTextField.text {
            let modifiedSearchText = modifySearchText(searchText)
            print(modifiedSearchText)
            
            weatherManager.fetchWeather(cityName: modifiedSearchText)
        }
        
        searchTextField.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type Something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            let modifiedCity = modifySearchText(city)
            weatherManager.fetchWeather(cityName: modifiedCity)
        }
        searchTextField.text = ""
    }
    
    func modifySearchText(_ searchText: String) -> String {
        var modifiedText = searchText
        let mappings = [
            "ü": "u",
            "ç": "c",
            "ş": "s",
            "ğ": "g",
            "İ": "I",
            "Ş": "S",
            "Ğ": "G"
            // Diğer Türkçe karakterlerin değişimlerini ekleyebilirsiniz
        ]
        
        for (searchChar, replacementChar) in mappings {
            modifiedText = modifiedText.replacingOccurrences(of: searchChar, with: replacementChar)
        }
        
        return modifiedText
    }
}


extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.tempratureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

    
    func didFailWithError(error: Error) {
        print(error)
    }


extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Reverse geocoding failed with error: \(error.localizedDescription)")
                    self.weatherManager.delegate?.didFailWithError(error: error)
                } else if let placemark = placemarks?.first {
                    if let city = placemark.locality {
                        let modifiedCity = city.replacingOccurrences(of: "ü", with: "u")
                                                .replacingOccurrences(of: "ç", with: "c")
                                                .replacingOccurrences(of: "ş", with: "s")
                                                .replacingOccurrences(of: "ğ", with: "g")
                                                .replacingOccurrences(of: "Ş", with: "S")
                                                .replacingOccurrences(of: "Ğ", with: "G")
                                                // Diğer Türkçe karakterlerin değişimlerini ekleyebilirsiniz
                        print("Current city: \(modifiedCity)")
                        self.weatherManager.fetchWeather(cityName: modifiedCity)
                    } else {
                        print("City information not found.")
                    }
                }
            }
        }
        print("Got location data.")
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

