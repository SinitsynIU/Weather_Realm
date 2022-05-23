//
//  HistoryViewController.swift
//  Weather
//
//  Created by Илья Синицын on 14.04.2022.
//

import UIKit
import CoreData
import RxCocoa
import RxSwift

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var historySegmentedControl: UISegmentedControl!
    @IBOutlet weak var clearBDButton: ButtonCustom!
    @IBOutlet weak var historyTabelView: UITableView!
    @IBOutlet weak var historyBgImage: UIImageView!
    @IBOutlet weak var historyLabel: UILabel!
    
    var weatherArray = BehaviorSubject<[(weather:WeatherJSON, date:Date)]>(value: [])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buttonIsHidden()
        setupLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(weatherDataBaseDidChange), name: NSNotification.Name("WeatherDataBaseDidChange"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabelView()
        historyTabelView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        MediaManager.shared.clearMediaPlayer()
    }
    
    @objc
    func weatherDataBaseDidChange() {
        // weatherArray.removeAll()
        historyTabelView.reloadData()
    }
    
    func buttonIsHidden() {
//        weatherArray
//            .filter { value in
//            value.count > 1
//            }
//            .subscribe(onNext: { [weak self] value in
//            self?.clearBDButton.isHidden = false
//            })
//            .disposed(by: disposeBag)
//        if weatherArray.count {
//            clearBDButton.isHidden = true
//        } else {
//            clearBDButton.isHidden = false
//        }
    }
   
    
    private func setupUI() {
        self.overrideUserInterfaceStyle = .light
        historyBgImage.backgroundColor = UIColor(white: 1, alpha: 0.5)
        clearBDButton.isHidden = true
    }
    
    private func setupTabelView() {
        historyTabelView.delegate = nil
        historyTabelView.dataSource = nil
        historyTabelView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        
        weatherArray
            .bind(to: historyTabelView.rx.items(cellIdentifier: "HistoryTableViewCell", cellType: HistoryTableViewCell.self)) { index, model, cell in
                
                cell.date = model.date
                cell.selectionStyle = .none
                cell.tempLabel.text = "\(Int(model.weather.main.temp ?? 0.0))°С"
                cell.containerActions.isHidden = true
                cell.deleteView?.play()
                if self.historySegmentedControl.selectedSegmentIndex == 0 {
                    cell.coordinateLabel.text = nil
                    cell.cityLabel.text = model.weather.name
                } else {
                    cell.coordinateLabel.text = "lat: \(model.weather.coord.lat ?? 0.0), lon: \(model.weather.coord.lon ?? 0.0)"
                    cell.cityLabel.text = nil
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let date: String =  dateFormatter.string(from: model.date)
                cell.dateTimeLabel.text = "\(date)"
                let icon: String = model.weather.weather.first?.icon ?? ""
                    FileServiceManager.shared.getWeatherImage(icon: icon, completed: { image in
                        cell.historyTempImageView.image = image
                    })
                
        }.disposed(by: disposeBag)
        
        historyTabelView
                .rx
                .setDelegate(self)
                .disposed(by: disposeBag)
    }
    
    private func setupLocalization() {
        historyLabel.text = NSLocalizedString("tabBarItem_title_history", comment: "")
        historySegmentedControl.setTitle(NSLocalizedString("segmentedIndex0_title_history", comment: ""), forSegmentAt: 0)
        historySegmentedControl.setTitle(NSLocalizedString("segmentedIndex1_title_history", comment: ""), forSegmentAt: 1)
        clearBDButton.text = NSLocalizedString("clearBDButton_text_history", comment: "")
    }
    
    @IBAction func historySegmentedControlAction(_ sender: UISegmentedControl) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.tap, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        
        if sender.selectedSegmentIndex == 0 {
            let parameters = CoreDataManager.shared.getWeatherSourceFromDB(source: SourceValues.city.rawValue)
            weatherArray.subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
            //weatherArray.removeAll()
            weatherArray.onNext(parameters)
        } else {
            let parameters = CoreDataManager.shared.getWeatherSourceFromDB(source: SourceValues.coordinate.rawValue)
            weatherArray.subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
            //weatherArray.removeAll()
            weatherArray.onNext(parameters)
        }
        
        historyTabelView.reloadData()
    }
    
    @IBAction func ClearBDAction(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.remove, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        CoreDataManager.shared.deleteWeatherAll()
        
        historyTabelView.reloadData()
    }
}

extension HistoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print(indexPath)

//        let weatherDB = fetchResultController.object(at: indexPath)
//        guard indexPath.section == 0 else { return }
//        if let vc = UIStoryboard(name: "HistoryWeatherInfoViewController", bundle: nil).instantiateInitialViewController() as? HistoryWeatherInfoViewController {
//            vc.modalPresentationStyle = .fullScreen
//            vc.modalTransitionStyle = .flipHorizontal
//            vc.weatherJ = weatherDB
//            self.present(vc, animated: true, completion: nil)
//        }
    }
}
