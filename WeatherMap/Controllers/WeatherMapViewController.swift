//
//  ViewController.swift
//  WeatherMap
//
//  Created by ADMIN ODoYal on 18.05.2021.
//

import UIKit
import Alamofire
import CoreLocation

protocol WeatherMapViewControllerDelegate: AnyObject {
    func setcityWeather(_  cityWeather: CityWeather)
}

class WeatherMapViewController: UIViewController {
    static let identifier = "WeatherMapViewController"
    static let nib = UINib(nibName: identifier, bundle: Bundle(for: WeatherMapViewController.self))
    
    private var locationManager: CLLocationManager?
    private var cityWeather: CityWeather? {
        didSet {
            if let cw = cityWeather {
                let dayPart = getDayPart(current: cw.currentUnixDateTime, seconds: cw.timezoneSeconds, sunrise: cw.sys?.sunriseUnixDateTime, sunset: cw.sys?.sunsetUnixDateTime)
                constDegreeLabel.isHidden = false
                weatherTypeBackImageView.image = UIImage(named: cw.weather?.first?.main ?? WeatherTypes.Error.rawValue)
                weatherTypeLabel.text = "\(dayPart), \(String(cw.weather?.first?.main ?? "No type" ))"
                dayPartBackImageView.image = UIImage(named: dayPart )
                cityNameLabel.text = cw.name
                temperatureLabel.text = getCorrectTemp(cw.temp?.temp)
            }
        }
    }
    private var weatherApi = WeatherApi()
    
    @IBOutlet weak var constDegreeLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak fileprivate var searchButton: UIButton!
    @IBOutlet weak fileprivate var temperatureLabel: UILabel!
    @IBOutlet weak fileprivate var weatherTypeLabel: UILabel!
    @IBOutlet weak fileprivate var dayPartBackImageView: UIImageView!
    @IBOutlet weak fileprivate var weatherTypeBackImageView: UIImageView!
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: SearchCityViewController.identifier) as! SearchCityViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if cityWeather == nil {
            cityNameLabel.text = ""
            temperatureLabel.text = ""
            weatherTypeLabel.text = ""
            constDegreeLabel.isHidden = true
        }
    }
}

// MARK: Internal func
extension WeatherMapViewController {
    func configureLayout() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
    
    private func getCorrectTemp(_ temp: Double?) -> String{
        guard let t = temp else {
            return ""
        }
        if t > -10 && t < 10 {
            return "0"+String(Int(t))
        } else{
            return String(Int(t))
        }
        
    }
    private func configureLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }
    
    private func getCityWeatherByCordinate(lat: Double, lon: Double) {
        AF.request(weatherApi.getHost(lat: lat, lon: lon), method: .get).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                guard let data = response.data else{return}
                do {
                    let cityWeatherJSON = try JSONDecoder().decode(CityWeather.self, from: data)
                    cityWeather = cityWeatherJSON
                } catch {
                    print(error)
                }
            case .failure(let error):
                print("API_PATH failed to retrive data!")
                print(error.errorDescription ?? "")
            }
        }
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "In order to deliver pizza we need your location",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: SearchCityViewController.identifier) as! SearchCityViewController
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func getDayPart(current currentUnix: Int?,
                            seconds timezone: Int?,
                            sunrise sunriseUnix: Int?,
                            sunset sunsetUnix: Int? ) -> DayParts.RawValue {
        guard let timezone = timezone else { return "" }
        guard let currentUnix = currentUnix else { return "" }
        guard let sunriseUnix = sunriseUnix else { return "" }
        guard let sunsetUnix = sunsetUnix else { return "" }
        
        let currentHour = Date(timeIntervalSince1970: TimeInterval(currentUnix + timezone))
        let sunsetHour = Date(timeIntervalSince1970: TimeInterval(sunsetUnix + timezone))
        let sunriseHour = Date(timeIntervalSince1970: TimeInterval(sunriseUnix + timezone))
        
        switch currentHour {
        case sunriseHour..<sunsetHour:
            return DayParts.Day.rawValue
        case sunsetHour...sunriseHour:
            return DayParts.Night.rawValue
        default:
            return DayParts.Eror.rawValue
        }
    }
}
// MARK: CLLocationManagerDelegate
extension WeatherMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            showLocationDisabledPopUp()
        case .authorizedAlways,.authorizedWhenInUse,.authorized:
            getCityWeatherByCordinate(lat: locationManager?.location?.coordinate.latitude ?? 0.0, lon: locationManager?.location?.coordinate.longitude ?? 0.0)
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        @unknown default:
            fatalError()
        }
    }
}

// MARK: WeatherMapViewControllerDelegate
extension WeatherMapViewController: WeatherMapViewControllerDelegate {
    func setcityWeather(_ cityWeather: CityWeather) {
        self.cityWeather = cityWeather
    }
}
