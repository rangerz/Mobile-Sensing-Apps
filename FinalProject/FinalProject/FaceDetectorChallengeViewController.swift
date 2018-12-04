//
//  FaceDetectorChallengeViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import AVFoundation

class FaceDetectorChallengeViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    
    var videoManager:VideoAnalgesic = VideoAnalgesic.sharedInstance
    var detector:CIDetector! = nil
    var notBlinkingCount: Int = 0
    var notBlinkingSeconds: Int = 0
    let totalSeconds: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = nil
        
        videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh, CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        videoManager.setProcessingBlock(newProcessBlock: processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
        // Turn label white
        countLabel.textColor = UIColor(white: 1, alpha: 1)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        turnOffVideo()
    }
    
    func turnOffVideo() {
        if videoManager.isRunning{
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [
            CIDetectorImageOrientation:self.videoManager.ciOrientation,
            CIDetectorEyeBlink:true,
            CIDetectorSmile:true
            ] as [String : Any]
        
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
    }
    
    func processImage(inputImage:CIImage) -> CIImage{
        // detect faces
        let f = getFaces(img: inputImage)
        
        // Check if blinking is detected
        updateFacesStatus(features: f)
        
        return inputImage
    }
    
    //MARK: Update Face UI Status
    func updateFacesStatus(features:[CIFaceFeature]) {
        let notBlink = notBlinking(features: features)
        
        if notBlink {
            // Add to not blinking count
            notBlinkingCount = notBlinkingCount + 1
        } else {
            // Reset count, since user blinked
            notBlinkingCount = 0
        }
        
        // Get how many seconds have passed
        let newSeconds: Int = Int(self.notBlinkingCount / 30)
        
        // Check if user has gotten N seconds not blinking (seconds * fps)
        DispatchQueue.main.async {
            if self.notBlinkingCount == self.totalSeconds * 30 {
                self.turnOffVideo()
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: AlarmOnViewController.notificationName, object: nil)
                })
            // If a new second passed, update label
            } else if newSeconds != self.notBlinkingSeconds {
                self.countLabel.text = "\(newSeconds)"
                self.notBlinkingSeconds = newSeconds
            }
        }
    }
    
    func notBlinking(features:[CIFaceFeature]) -> Bool {
        // If no face detected, challenge is not counting
        if 0 == features.count {
            return false
        } else {
            // If one eye blinking is detected, return false
            for f in features {
                if f.leftEyeClosed {
                    return false
                }
                if f.rightEyeClosed {
                    return false
                }
            }
        }
        // Face is detected, but not blinking
        return true
    }
}
