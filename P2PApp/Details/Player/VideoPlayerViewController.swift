//
//  VideoPlayerViewController.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 03/10/23.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayerViewController: AVPlayerViewController {
    
    var dataUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchAndPlayVideo()
    }
    
    func fetchAndPlayVideo() {
        DispatchQueue.main.async {
            let url = self.dataUrl ?? "";
            guard let assetUrl = URL(string: url) else { return }
            let assets = AVAsset(url: assetUrl)
            let playerItem = AVPlayerItem(asset: assets)
            self.videoGravity = .resizeAspect
            self.player = AVPlayer(playerItem: playerItem)
            self.player?.play()
        }
    }
}
