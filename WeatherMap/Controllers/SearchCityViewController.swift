//
//  SearchCityViewController.swift
//  WeatherMap
//
//  Created by ADMIN ODoYal on 19.05.2021.
//

import UIKit
import Alamofire

class SearchCityViewController: UIViewController {
    static let identifier = "SearchCityViewController"
    static let nib = UINib(nibName: identifier, bundle: Bundle(for: SearchCityViewController.self))
    private let weatherApi = WeatherApi()
    public weak var delegate: WeatherMapViewControllerDelegate?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let text = cityNameTextField.text, text != ""{
            searchButton.isEnabled = false
            getCityWeatherByName(name: text)
        }
    }
}

// MARK: Initial func
extension SearchCityViewController {
    private func getCityWeatherByName(name: String) {
        defer {
            searchButton.isEnabled = true
        }
        AF.request(weatherApi.getHost(with: name), method: .get).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                guard let data = response.data else{return}
                    do {
                        let cityWeatherJSON = try JSONDecoder().decode(CityWeather.self, from: data)
                        guard let _ = cityWeatherJSON.name else {
                            setOkAlertMessage(with: "There is no place with such name")
                            return
                        }
                        delegate?.setcityWeather(cityWeatherJSON)
                        cityNameTextField.text = ""
                        navigationController?.popViewController(animated: true)
                    } catch {
                        print(error)
                    }
            case .failure(let error):
                print("API_PATH failed to retrive data!")
                print(error.errorDescription ?? "")
                setOkAlertMessage(with: "Do not use space")
            }
        }
    }
    
    private func setOkAlertMessage(with message: String){
        let allertController = UIAlertController(
            title: "Message",
            message: message,
            preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        allertController.addAction(okAlertAction)
        self.present(allertController, animated: true, completion: nil)
    }
}
