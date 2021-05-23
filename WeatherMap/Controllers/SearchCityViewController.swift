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
    public var setDayPartBackImageCallBack: (()->String)?
    public var setTypeBackImageCallBack: (()->String)?
    @IBOutlet weak var clearSearchTextFieldButton: UIButton!
    @IBOutlet weak fileprivate var backButton: UIButton!
    @IBOutlet weak fileprivate var locationNameTextField: UITextField!
    @IBOutlet weak fileprivate var searchButton: UIButton!
    @IBOutlet weak fileprivate var dayPartBackImageView: UIImageView!
    @IBOutlet weak fileprivate var weatherTypeBackImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    @IBAction func locationNameTextFieldEditing(_ sender: Any) {
        checkClearSearchButton()
    }
    
    @IBAction func clearSearchTextFieldButtonPressed(_ sender: Any) {
        locationNameTextField.text = ""
        clearSearchTextFieldButton.isHidden = true
        clearSearchTextFieldButton.isEnabled = false
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let text = locationNameTextField.text, text != ""{
            searchButton.isEnabled = false
            getCityWeatherByName(name: text)
        }
    }
}

// MARK: Initial func
extension SearchCityViewController {
    private func configureLayout() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(searchFieldEndEditing))
        self.view.addGestureRecognizer(tapOnView)
    }
    
    @objc private func searchFieldEndEditing() {
        locationNameTextField.endEditing(true)
    }
    
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
                    locationNameTextField.text = ""
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
    
    fileprivate func checkClearSearchButton() {
        if locationNameTextField.text == "" {
            clearSearchTextFieldButton.isEnabled = false
            clearSearchTextFieldButton.isHidden = true
        } else {
            clearSearchTextFieldButton.isEnabled = true
            clearSearchTextFieldButton.isHidden = false
        }
    }
}
