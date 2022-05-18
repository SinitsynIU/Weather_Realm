//
//  SearchNewsViewController.swift
//  Weather
//
//  Created by Илья Синицын on 24.03.2022.
//

import UIKit
import NVActivityIndicatorView
import GoogleMobileAds

class SearchNewsViewController: UIViewController {
    
    enum PaginationState: String {
        case pagingIsReady, isPaging, pagingEnd
    }
    
    @IBOutlet weak var blurActivityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var newsTabelView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var news: NewsJSON? = nil
    let navBar = UINavigationController()
    private var state: PaginationState = .pagingIsReady
    private var page: Int = 1
    var timer: Timer?
    var controlGetMetod: Int?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideKeyboardWhenTappedAround()
        setupUI()
        setupTabelView()
        setupSearchBar()
        setupLocalization()
        activityIndicatorView.startAnimating()
        getNewsCountryData(page: 0)
    }
    
    private func setupUI() {
        self.overrideUserInterfaceStyle = .light
        blur.isHidden = true
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.backgroundColor = .white
        
    }
    
    private func setupLocalization() {
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("tabBarItem_title_news", comment: "")
    }
    
    private func setupTabelView() {
        newsTabelView.delegate = self
        newsTabelView.dataSource = self
        newsTabelView.register(UINib(nibName: "newsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
    }
    
    func getNewsData(page: Int = 1, search: String) {
        controlGetMetod = 1
        guard state == .pagingIsReady else { return }
        state = .isPaging
        NetworkServiceManager.shared.getNewsJSON(search: search, completion: { [weak self] (result) in
            switch result {
            case .success(let newsJSON):
                self?.page += 1
                self?.news = newsJSON
                self?.state = newsJSON.articles?.count == 0 ? .pagingEnd : .pagingIsReady
                self?.activityIndicatorView.stopAnimating()
                self?.blurActivityIndicatorView.stopAnimating()
                self?.newsTabelView.reloadData()
                self?.controlGetMetod = nil
                //print("News/newsJSON", newsJSON)
            case .failure(let error):
                self?.state = .pagingIsReady
                self?.activityIndicatorView.stopAnimating()
                self?.showAlert(with: "\(error.localizedDescription)")
            }
        })
    }
    
    func getNewsCountryData(page: Int = 1) {
        guard state == .pagingIsReady else { return }
        state = .isPaging
        NetworkServiceManager.shared.getNewsCountryJSON(completion: { [weak self] (result) in
            switch result {
            case .success(let newsJSON):
                self?.page += 1
                self?.news = newsJSON
                self?.state = newsJSON.articles?.count == 0 ? .pagingEnd : .pagingIsReady
                self?.activityIndicatorView.stopAnimating()
                self?.blurActivityIndicatorView.stopAnimating()
                self?.newsTabelView.reloadData()
                //print("News/newsJSON", newsJSON)
            case .failure(let error):
                self?.state = .pagingIsReady
                self?.activityIndicatorView.stopAnimating()
                self?.showAlert(with: "\(error.localizedDescription)")
            }
        })
    }
}

extension SearchNewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news?.articles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as? newsCell else { return UITableViewCell() }
        let newsJ = news?.articles?[indexPath.row]
        cell.titleLabel.text = newsJ?.title ?? ""
        cell.resourceLabel.text = newsJ?.source.name ?? ""
        let imageUrl = newsJ?.urlToImage ?? ""
        FileServiceManager.shared.getNewsImage(imageUrl: imageUrl, completed: { image in
        cell.authorImageView.image = image
        })
        return cell
    }
}

extension SearchNewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 0 else { return }
        selectedIndex = indexPath.row
        blur.isHidden = false
        blurActivityIndicatorView.startAnimating()
        AdsManager.shared.setupRewarded(viewController: self) { [weak self] in
            self?.blurActivityIndicatorView.stopAnimating()
        } onError: { [weak self] in
            print("Failed to load rewarded ad with error")
            if let vc = UIStoryboard(name: "PostNewsViewController", bundle: nil).instantiateInitialViewController() as? PostNewsViewController, let index = self?.selectedIndex {
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .flipHorizontal
                let newsJ = self?.news?.articles?[index]
                vc.newsJ = newsJ
                self?.present(vc, animated: true, completion: nil)
            }
            self?.selectedIndex = nil
            self?.blur.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if controlGetMetod == 1 { 
            if indexPath.row == (news?.articles?.count ?? 0) - 1 {
                activityIndicatorView.startAnimating()
                self.getNewsData(page: self.page, search: "")
            }
        } else {
            if indexPath.row == (news?.articles?.count ?? 0) - 1 {
                activityIndicatorView.startAnimating()
                self.getNewsCountryData(page: self.page)
            }
        }
    }
}

extension SearchNewsViewController: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        newsTabelView.reloadData()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.blurActivityIndicatorView.startAnimating()
            self.getNewsData(page: 0, search: searchText)
        })
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.blurActivityIndicatorView.startAnimating()
        self.getNewsCountryData(page: 0)
    }
}

extension SearchNewsViewController: GADFullScreenContentDelegate {
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if let vc = UIStoryboard(name: "PostNewsViewController", bundle: nil).instantiateInitialViewController() as? PostNewsViewController, let index = selectedIndex {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            let newsJ = news?.articles?[index]
            vc.newsJ = newsJ
            self.present(vc, animated: true, completion: {
                self.blur.isHidden = true
            })
        }
        selectedIndex = nil
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if let vc = UIStoryboard(name: "PostNewsViewController", bundle: nil).instantiateInitialViewController() as? PostNewsViewController, let index = selectedIndex {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            let newsJ = news?.articles?[index]
            vc.newsJ = newsJ
            self.present(vc, animated: true, completion: {
                self.blur.isHidden = true
            })
        }
        selectedIndex = nil
    }
}
