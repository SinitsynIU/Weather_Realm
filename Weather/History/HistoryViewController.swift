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
    
   // var weatherSubject = BehaviorSubject<WeatherDB>(value: WeatherDB())
    var fetchResultController: NSFetchedResultsController<WeatherDB>!
    //let disposeBag = DisposeBag()
    
    //let weatherArray: [WeatherDB] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocalization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(weatherDataBaseDidChange), name: NSNotification.Name("WeatherDataBaseDidChange"), object: nil)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabelView()
        fetchRequest()
        historyTabelView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        MediaManager.shared.clearMediaPlayer()
    }
    
    @objc
    func weatherDataBaseDidChange() {
        fetchRequest()
        historyTabelView.reloadData()
    }
    
    private func setupUI() {
        self.overrideUserInterfaceStyle = .light
        historyBgImage.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
    private func setupTabelView() {
        historyTabelView.delegate = self
        historyTabelView.dataSource = self
        historyTabelView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        
//        weatherSubject
//            .bind(to: historyTabelView.rx.items(cellIdentifier: "HistoryTableViewCell", cellType: HistoryTableViewCell.self)) { index, model, cell in
                
           // let weatherDB = fetchResultController.object(at: model)
//            cell.date = weatherDB.date
//            cell.selectionStyle = .none
//            cell.tempLabel.text = "\(Int(weatherDB.temp))°С"
//            cell.containerActions.isHidden = true
//            cell.deleteView?.play()
//            if self.historySegmentedControl.selectedSegmentIndex == 0 {
//                cell.coordinateLabel.text = nil
//                cell.cityLabel.text = weatherDB.city
//            } else {
//                cell.coordinateLabel.text = "lat: \(weatherDB.lat), lon: \(weatherDB.lon)"
//                cell.cityLabel.text = nil
//            }
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
//            let date: String =  dateFormatter.string(from: weatherDB.date ?? Date.now)
//            cell.dateTimeLabel.text = "\(date)"
//            let icon: String = weatherDB.icon ?? ""
//                FileServiceManager.shared.getWeatherImage(icon: icon, completed: { image in
//                    cell.historyTempImageView.image = image
//                })
                
       // }.disposed(by: disposeBag)
    }
    
    private func setupLocalization() {
        historyLabel.text = NSLocalizedString("tabBarItem_title_history", comment: "")
        historySegmentedControl.setTitle(NSLocalizedString("segmentedIndex0_title_history", comment: ""), forSegmentAt: 0)
        historySegmentedControl.setTitle(NSLocalizedString("segmentedIndex1_title_history", comment: ""), forSegmentAt: 1)
        clearBDButton.text = NSLocalizedString("clearBDButton_text_history", comment: "")
    }
    
    private func fetchRequest() {
        let fetchRequest: NSFetchRequest<WeatherDB>
        if historySegmentedControl.selectedSegmentIndex == 0 {
            fetchRequest = WeatherDB.fetchRequest(source: SourceValues.city.rawValue)
        } else {
            fetchRequest = WeatherDB.fetchRequest(source: SourceValues.coordinate.rawValue)
        }
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchResultController.performFetch()
    }
    
    @IBAction func historySegmentedControlAction(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.tap, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        fetchRequest()
        historyTabelView.reloadData()
    }
    
    @IBAction func ClearBDAction(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.remove, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        CoreDataManager.shared.deleteWeatherAll()
        fetchRequest()
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

extension HistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchResultController.sections?[section].numberOfObjects == 0 {
            clearBDButton.isHidden = true
        } else {
            clearBDButton.isHidden = false
        }
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as? HistoryTableViewCell else { return UITableViewCell() }
        let weatherDB = fetchResultController.object(at: indexPath)
        cell.date = weatherDB.date
        cell.selectionStyle = .none
        cell.tempLabel.text = "\(Int(weatherDB.temp))°С"
        cell.containerActions.isHidden = true
        cell.deleteView?.play()
        if historySegmentedControl.selectedSegmentIndex == 0 {
            cell.coordinateLabel.text = nil
            cell.cityLabel.text = weatherDB.city
        } else {
            cell.coordinateLabel.text = "lat: \(weatherDB.lat), lon: \(weatherDB.lon)"
            cell.cityLabel.text = nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let date: String =  dateFormatter.string(from: weatherDB.date ?? Date.now)
        cell.dateTimeLabel.text = "\(date)"
        let icon: String = weatherDB.icon ?? ""
            FileServiceManager.shared.getWeatherImage(icon: icon, completed: { image in
                cell.historyTempImageView.image = image
            })
        return cell
    }
}
