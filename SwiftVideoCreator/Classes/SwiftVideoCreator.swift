//
//  SwiftVideoCreator.swift
//  Snip Video Creator
//
//  Created by Lexie Kemp on 9/7/19.
//  Copyright © 2019 Lexie Kemp. All rights reserved.
//
import AVFoundation

public class SwiftVideoCreator {
    open class var current: SwiftVideoCreator {
        struct Static {
            static var instance = SwiftVideoCreator()
        }
        
        return Static.instance
    }
    
    /*create an m4v video composition from a video on top of an image and audio
   
    Composition size is the dimensions of the saved video composition
    Video size is the dimensions of the video that is on top of the image
    Origin is the bottom left corner
    
     example with video and audio as a file in the project, image in assets:
     
 guard let videoPath = Bundle.main.path(forResource: "myVideo", ofType:"mov") else {
     print("myVideo.mov not found")
     return
 }
 let videoUrl = URL(fileURLWithPath: videoPath)
 
 guard let audioPath = Bundle.main.path(forResource: "myAudio", ofType:"mp3") else {
     print("myAudio.mp3 not found")
     return
 }
 let audioUrl = URL(fileURLWithPath: audioPath)
 
 //for image in assets
 guard let backgroundImage = UIImage(named: "myBackgroundImage") else {
     print("Background Image not found in Assets")
     return
 }
 guard let cgBackgroundImage = backgroundImage.cgImage else {
     print("could not convert background image to cgImage")
     return
 }
 */
    open func createVideo(fileName: String, compositionSize: CGSize, videoUrl: URL, videoSize: CGSize, videoOrigin: CGPoint, videoOpacity: Float, audioUrl: URL, image: CGImage, imageOrigin: CGPoint, imageSize: CGSize, imageOpacity: Float, success: @escaping ((URL) -> Void), failure: @escaping ((Error) -> Void)) {
        
        //first put wave animation and audio together
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        
        guard let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Error creating video or audio track")
            return
        }
        mutableCompositionVideoTrack.append(videoTrack)
        mutableCompositionAudioTrack.append(audioTrack)
        
        guard let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first else {
            print("Error creating video or audio track")
            return
        }
        
        do {
            try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aAudioAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
            try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aAudioAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
            
        } catch{
            print("Error creating video composition")
            print(error)
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aAudioAssetTrack.timeRange.duration)
        
        
        let videoLayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        videoLayerInstruction.setOpacity(0.0, at: aVideoAsset.duration)
        totalVideoCompositionInstruction.layerInstructions = [videoLayerInstruction]
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderScale = 1.0
        
        mutableVideoComposition.renderSize = compositionSize
        mutableVideoComposition.instructions = [totalVideoCompositionInstruction]
        
        //but video over the background image
        let backgroundLayer = CALayer()
        let videoLayer = CALayer()
        let parentLayer = CALayer()
        
        
        backgroundLayer.contents = image
        backgroundLayer.frame = CGRect(x: imageOrigin.x, y: imageOrigin.y, width: imageSize.width, height: imageSize.height);
        backgroundLayer.masksToBounds = true
        backgroundLayer.opacity = imageOpacity
        
        videoLayer.frame = CGRect(x: videoOrigin.x, y: videoOrigin.y, width: videoSize.width, height: videoSize.height)
        videoLayer.opacity = videoOpacity
        
        
        parentLayer.frame = CGRect(x: 0, y: 0, width: compositionSize.width, height: compositionSize.height);
        parentLayer.addSublayer(backgroundLayer)
        parentLayer.addSublayer(videoLayer)
        
        mutableVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        //export the video
        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\(fileName).m4v")
            
            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch {
                print("Error removing existing file at filePath")
            }
            
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.videoComposition = mutableVideoComposition
                
                // try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .failed:
                        print("Error: exporting video failed")
                        if let _error = exportSession.error {
                            failure(_error)
                        }
                    case .cancelled:
                        print("Error: exporting video cancelled")
                        if let _error = exportSession.error {
                            failure(_error)
                        }
                    default:
                        success(outputURL)
                    }
                })
            } else {
                print("Error: exporting video failed")
            }
        }
    }
}
