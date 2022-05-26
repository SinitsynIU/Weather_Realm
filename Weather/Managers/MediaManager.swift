//
//  MediaManager.swift
//  Weather
//
//  Created by Илья Синицын on 26.04.2022.
//

import AVKit

class MediaManager {
    static let shared = MediaManager()
    
    enum ResourceBundleValues: String {
        case clear
        case rain
        case snow
        case clouds
        case wind
        case click
        case close
        case remove
        case tap
    }
    
    var backgroundVideoPlayerViewLayer: AVPlayerLayer?
    var playerAudio: AVPlayer?
    var playerVideo: AVPlayer?
    
    func playerAudioSettings(bundleResource: ResourceBundleValues, notificationOn: Bool) {
        guard let url = Bundle.main.url(forResource: bundleResource.rawValue, withExtension: "mp3") else { return }
        playerAudio = AVPlayer(url: url)
        
        if notificationOn == true {
            NotificationCenter.default.addObserver(self, selector: #selector(audioDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerAudio?.currentItem)
        }
    }
    
    @objc func audioDidEnd(_ notification: Notification) {
        playerAudio?.seek(to: .zero)
        playerAudio?.play()
    }
    
    func playerVideoSettings(bundleResource: ResourceBundleValues, view: UIView, notificationOn: Bool) {
        guard let url = Bundle.main.url(forResource: bundleResource.rawValue, withExtension: "mp4") else { return }
        playerVideo = AVPlayer(url: url)
        backgroundVideoPlayerViewLayer = AVPlayerLayer(player: playerVideo)
        backgroundVideoPlayerViewLayer?.videoGravity = .resizeAspectFill
        backgroundVideoPlayerViewLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundVideoPlayerViewLayer!, at: 0)
        
        if notificationOn == true {
            NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerVideo?.currentItem)
        }
    }
    
    @objc func videoDidEnd(_ notification: Notification) {
        playerVideo?.seek(to: .zero)
        playerVideo?.play()
    }
    
    func playerAudioPlay() {
        playerAudio?.play()
        playerAudio?.volume = 0.2
    }
    
    func playerVideoPlay() {
        playerVideo?.play()
    }
    
    func notificationRemove() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func clearAudioPlayer() {
        playerAudio?.pause()
        playerAudio = nil
    }
    func clearVideoPlayer() {
        playerVideo?.pause()
        playerVideo = nil
        backgroundVideoPlayerViewLayer?.removeFromSuperlayer()
        backgroundVideoPlayerViewLayer = nil
    }
}
