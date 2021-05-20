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
                
                weatherTypeLabel.text = String(cw.weather?.first?.main ?? "No type")
                cityNameLabel.text = cw.name
                temperatureLabel.text = getCorrectTemp(cw.temp?.temp)
                print(temperatureLabel.text ?? "0.0")
            }
        }
    }
    private var weatherApi = WeatherApi()

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak fileprivate var searchButton: UIButton!
    @IBOutlet weak fileprivate var temperatureLabel: UILabel!
    @IBOutlet weak fileprivate var weatherTypeLabel: UILabel!
    @IBOutlet weak fileprivate var backgorundImageView: UIImageView!
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: SearchCityViewController.identifier) as! SearchCityViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
}
    
// MARK: Internal func
extension WeatherMapViewController {
    private func getCorrectTemp(_ temp: Double?) -> String{
        guard let t = temp else {
            return ""
        }
        if t > -10 && t < 10 {
            return "  0"+String(Int(t))+"˚"
        } else{
            return "  "+String(Int(t))+"˚"
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
}
// MARK: CLLocationManagerDelegate
extension WeatherMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .denied:
                showLocationDisabledPopUp()
            case .authorizedAlways,.authorizedWhenInUse:
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
