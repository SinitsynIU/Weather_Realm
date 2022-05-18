//
//  HistoryTableViewCell.swift
//  Weather
//
//  Created by Илья Синицын on 14.04.2022.
//

import UIKit
import Lottie

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerActions: UIView!
    @IBOutlet weak var deleteView: AnimationView?
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var historyTempImageView: UIImageView!
    
    var date: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentViewCell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        contentViewCell.layer.cornerRadius = 25
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        containerView.layer.cornerRadius = 25
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.delegate = self
        containerView.addGestureRecognizer(panGesture)
    }
    
    @objc func panGestureAction (_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: containerView)
            sender.setTranslation(.zero, in: containerView)
            guard translation.x < 0 || containerView.frame.origin.x < 0 else { return }
            containerView.frame.origin.x += translation.x
            self.containerActions.isHidden = false
        case .cancelled, .ended, .failed:
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                if self.containerView.frame.origin.x < -self.containerActions.bounds.width {
                    self.containerView.frame.origin.x = -self.containerActions.bounds.width
                } else {
                    if self.containerView.frame.origin.x > 0 {
                        self.containerView.frame.origin.x = 0
                        self.containerActions.isHidden = true
                    } else {
                        if abs(self.containerView.frame.origin.x) > (self.containerActions.bounds.width / 2) {
                            self.containerView.frame.origin.x = -self.containerActions.bounds.width
                            self.containerActions.isHidden = false
                        } else {
                            self.containerView.frame.origin.x = 0
                            self.containerActions.isHidden = true
                        }
                    }
                }
            }
        default: break
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        CoreDataManager.shared.deleteWeather(date: date ?? Date.now)
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.remove, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
