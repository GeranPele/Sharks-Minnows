//
//  MainMenuViewController.swift
//  Sharks&Minnows
//
//  Created by Geran Pele on 5/16/20.
//  Copyright © 2020 Geran Pele. All rights reserved.
//

import UIKit
import AVFoundation

class MainMenuViewController: UIViewController {
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Background Video
        let videoURL = Bundle.main.url(forResource: "art.scnassets/menuBackgroundVideo", withExtension: "mp4")

        avPlayer = AVPlayer(url: videoURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(playerItemDidReachEnd(notification:)),
        name: .AVPlayerItemDidPlayToEndTime,
        object: avPlayer.currentItem)
        
        //Blur the background video
        let blurEffect = UIBlurEffect(style: .regular)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.bounds
        view.insertSubview(blurredEffectView, at: 1)
        
    }
    
    @objc func playerItemDidReachEnd(notification: Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: .zero, completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        avPlayer.rate = 0.8
        paused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        avPlayer.pause()
        paused = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
