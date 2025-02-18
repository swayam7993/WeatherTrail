//
//  weatherVC.swift
//  WeatherTrail
//
//  Created by comviva on 05/02/22.
//

import UIKit

class weatherVC: UIViewController {
    
    
    @IBOutlet weak var currentL: UILabel!
    
    @IBOutlet weak var DateL: UILabel!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var temperatureL: UILabel!
    @IBOutlet weak var forecastL: UILabel!
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var windDir: UIImageView!
    
    let forecastVM = ForecastWeatherViewModel()
    var currentLocation=""
    var currentLat:Double = 0.0
    var currentLong:Double = 0.0
    var currentUnit = ""
    var excludeThis = ""
    var currentForecastType = ""
    
    var Wutils = weatherUtility()
    
    var getCurrentUnit:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.dataSource = self
        tbl.delegate = self
        tbl.backgroundColor = UIColor.clear
        currentL.text = "Location: \(currentLocation)"

        forecastVM.getWeatherData(Lat: currentLat, Long: currentLong, unit: currentUnit, exclude: excludeThis) {
            self.tbl.reloadData()
        }
        DateL.text = Date().description(with: .current)
//        print("currentLat:\(currentLat)")
//        print("currentLong:\(currentLong)")
        print("ExludedForecast: \(excludeThis)")
        print("current FOrecast Type: \(currentForecastType)")
        getCurrentUnit = Wutils.getTeempUnit(selectedUnit: currentUnit)
        // Do any additional setup after loading the view.
    }
    
}
// MARK: - Table DataSource


extension weatherVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentForecastType=="daily"{
            return forecastVM.weatherList.count
        }
        else{
            return (forecastVM.hourlyList.count-24)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentForecastType{
        case "daily":
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! WeatherCell
            let std = forecastVM.weatherList[indexPath.row] //weatherList[indexPath.row]
            cell.contentView.backgroundColor = UIColor.clear

            //DateL.text = Wutils.getDate(dt: std.dt)
            bgImg.image = Wutils.getBackground(main: std.weather[0].main)
            let windDegree = std.wind_deg
            windDir.image = Wutils.getWindArrow(dir: windDegree)
            let days = Wutils.getDay(dt: std.dt)
            print("\(days)")
            let imgURL = "http://openweathermap.org/img/wn/\(std.weather[0].icon)@2x.png"// HTTP does not work need change info.plist to make it work
            AFUtility.instance.downloadImage(imgURL: imgURL) { (imgData) in
                cell.forecastImg.image = UIImage(data: imgData)
            }
            forecastL.text = "\(std.weather[0].main)"
            cell.dayL.text = "\(days)"
            cell.maxT.text = "\(std.temp.max) \(getCurrentUnit[0])"
            cell.minT.text = "\(std.temp.min) \(getCurrentUnit[0])"
            temperatureL.text="\(std.temp.max)\(getCurrentUnit[0])"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "hourCell", for: indexPath) as! HourlyCell
            let std = forecastVM.hourlyList[indexPath.row]
            cell.contentView.backgroundColor = UIColor.clear
            //DateL.text = Wutils.getDate(dt: std.dt)
            bgImg.image = Wutils.getBackground(main: std.weather[0].main)
            let windDegree = std.wind_deg
            windDir.image = Wutils.getWindArrow(dir: windDegree)
            let days = Wutils.getTime(dt: std.dt)
            print("\(days)")
            let imgURL = "http://openweathermap.org/img/wn/\(std.weather[0].icon)@2x.png"// HTTP does not work
            forecastVM.getImages(imgURL: imgURL) { (imgData) in
                cell.conditionsL.image = UIImage(data: imgData)
            }
            forecastL.text = "\(std.weather[0].main)"
            temperatureL.text = "\(std.temp) \(getCurrentUnit[0])"
            cell.tempCellL.text="\(std.temp) \(getCurrentUnit[0])"
            cell.hourL.text = "\(days)"
            cell.humidityL.text = "Humidity:\(std.humidity)%"
            cell.feelLikeL.text = "Feels like \(std.feels_like)\(getCurrentUnit[0])"
            
            return cell
        }
        
    }
}

// MARK: - Table DataDelegate


extension weatherVC:UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let std = weatherList[indexPath.row]
//        print("Day:\(std.day) Temp:\(std.maxT)")
//        temperatureL.text="\(std.maxT)\u{00B0}C"
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let dayName = UILabel()
//        dayName.text="Days"
//        return dayName
//    }
//
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        //let std = weatherList[indexPath.row]
        switch currentForecastType{
        case "daily":
            let std = forecastVM.weatherList[indexPath.row]
            let windDegree = std.wind_deg
            windDir.image = Wutils.getWindArrow(dir: windDegree)
            print("Day:\(std.dt) Temp:\(std.temp.max)")
            temperatureL.text="\(std.temp.max)\(getCurrentUnit[0])"
            forecastL.text = "\(std.weather[0].main)"
        default:
            let std = forecastVM.hourlyList[indexPath.row]
            let windDegree = std.wind_deg
            windDir.image = Wutils.getWindArrow(dir: windDegree)
            print("Day:\(std.dt) Temp:\(std.feels_like )\(getCurrentUnit[0])")
            temperatureL.text="\(std.temp)\(getCurrentUnit[0])"
            forecastL.text = "\(std.weather[0].main)"
        }
    }
}
