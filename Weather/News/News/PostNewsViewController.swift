//
//  PostNewsViewController.swift
//  Weather
//
//  Created by Илья Синицын on 25.03.2022.
//

import UIKit
import ActiveLabel
import Lottie

class PostNewsViewController: UIViewController {
    
    @IBOutlet weak var closeView: AnimationView!
    @IBOutlet weak var posterView: UIView!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var posterBgImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var resourceNameLabel: UILabel!
    @IBOutlet weak var textPublishedLabel: UILabel!
    @IBOutlet weak var urlPostLabel: ActiveLabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var newsJ: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getImage()
        getDate()
    }
    
    deinit {
        MediaManager.shared.clearAudioPlayer()
        MediaManager.shared.notificationRemove()
    }
    
    private func setupUI() {
        self.overrideUserInterfaceStyle = .light
        closeView.play()
        posterView.layer.cornerRadius = 50
        posterBgImageView.layer.cornerRadius = 50
        posterBgImageView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        posterImageView.layer.cornerRadius = 50
        urlPostLabel.numberOfLines = 0
        urlPostLabel.enabledTypes = [.url]
        urlPostLabel.text = newsJ?.url ?? ""
        authorLabel.text = newsJ?.author ?? ""
        textPublishedLabel.text = newsJ?.articleDescription ?? ""
        resourceNameLabel.text = newsJ?.source.name ?? ""
    }
    
    private func getImage() {
        let imageUrl = newsJ?.urlToImage ?? ""
        FileServiceManager.shared.getNewsImage(imageUrl: imageUrl, completed: { [weak self] image in
            self?.posterImageView.image = image
        })
    }
    
    private func getDate() {
        let stringDate: String? = newsJ?.publishedAt ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: stringDate ?? "")
        let dF = DateFormatter()
        dF.dateFormat = "dd-MM-yyyy"
        let newStringDate = dF.string(from: date ?? Date.now)
        publishedLabel.text = newStringDate
    }
    
    @IBAction func urlPostTapGestureRecognizerAction(_ sender: Any) {
        if let url = URL(string: urlPostLabel.text ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func closeVCTapActions(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.close, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        dismiss(animated: true)
    }
}
