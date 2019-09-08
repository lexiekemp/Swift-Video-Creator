//
//  ViewController.swift
//  SwiftVideoCreator
//
//  Created by Lexie Kemp on 09/07/2019.
//  Copyright (c) 2019 Lexie Kemp. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SwiftVideoCreator

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let wavePath = Bundle.main.path(forResource: "wave", ofType:"mov") else {
            print("wave.mov not found")
            return
        }
        let waveUrl = URL(fileURLWithPath: wavePath)
        
        guard let audioPath = Bundle.main.path(forResource: "EndlessRoad", ofType:"mp3") else {
            print("EndlessRoad.mp3 not found")
            return
        }
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        guard let backgroundImage = UIImage(named: "Sunset") else {
            print("Sunet Image not found in Assets")
            return
        }
        guard let cgBackgroundImage = backgroundImage.cgImage else {
            print("could not convert background image to cgImage")
            return
        }
        
        SwiftVideoCreator.current.createVideo(fileName: "exampleVideo", compositionSize: CGSize(width: 360, height: 360), videoUrl: waveUrl, videoSize: CGSize(width: 360, height: 90), videoOrigin: CGPoint(x: 0, y: 100), videoOpacity: 0.7, audioUrl: audioUrl, image: cgBackgroundImage, imageOrigin: CGPoint(x: 0, y: 0), imageSize: CGSize(width: 360, height: 360), imageOpacity: 1.0,
                                      success: { url in
                                        print(url)
                                        self.playVideo(videoUrl: url)
        }, failure: { error in
            print("video creation failed with error \(error)")
        }
        )
    }
    
    func playVideo(videoUrl: URL) {
        let player = AVPlayer(url: videoUrl)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        present(playerVC, animated: true) {
            player.play()
        }
    }
}

