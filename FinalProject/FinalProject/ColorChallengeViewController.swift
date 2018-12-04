//
//  ColorChallengeViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/4/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit

class ColorChallengeViewController: UIViewController {
    @IBOutlet weak var colorLabel: UILabel!
    
    var videoManager:VideoAnalgesic = VideoAnalgesic.sharedInstance
    let bridge = OpenCVBridgeSub()
    var targetColor: [Int] = [0, 0, 0] // This will hold the RGB values for the target color
    var completedWaiting: Bool = false // Hold a variable to not dismiss very fast

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        videoManager.setProcessingBlock(newProcessBlock: processImage)
        if !videoManager.isRunning{
            videoManager.start()
        }
        
        colorLabel.textColor = UIColor(white: 1, alpha: 1)
        getTargetColor()
    }
    
    func turnOffVideo() {
        if videoManager.isRunning{
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }
    
    func processImage(inputImage:CIImage) -> CIImage{
        var retImage = inputImage
        var red:Float! = 0.0
        var green:Float! = 0.0
        var blue:Float! = 0.0
        
        // Check if it's not just waiting to dismiss
        if !completedWaiting {
            if AVCaptureDevice.Position.back == self.videoManager.getCameraPostion() {
                self.bridge.setTransforms(self.videoManager.transform)
                self.bridge.setImage(retImage,
                                     withBounds: retImage.extent, // the first face bounds
                    andContext: self.videoManager.getCIContext())
                self.bridge.getColorMean(&red, withGreen:&green, andBlue:&blue)
                retImage = self.bridge.getImageComposite()
                let completed = checkCovered(red:red, green:green, blue:blue)
                
                if completed {
                    self.completedWaiting = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.turnOffVideo()
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: AlarmOnViewController.notificationName, object: nil)
                        })
                    })
                }
            }
        }
        
        return inputImage
    }
    
    func checkCovered(red: Float, green: Float, blue: Float) -> Bool{
        // Get an absolute difference between each color channel
        let redDiff = abs(targetColor[0] - Int(red))
        let greenDiff = abs(targetColor[1] - Int(green))
        let blueDiff = abs(targetColor[2] - Int(blue))
        let threshold = 30
        
        // Determine if asked color is matched in video
        if (redDiff + greenDiff + blueDiff < threshold) {
            return true
        }
        
        return false
    }
    
    func getTargetColor() {
        let redAvg = [170, 54, 62]
        let blueAvg = [80, 80, 97]
        let yellowAvg = [159, 135, 82]
        
        // Select an index. Max value should be number of colors available
        let colorIndex = Int.random(in: 0 ..< 3)
        
        switch colorIndex {
        case 0:
            colorLabel.text = "red"
            targetColor = redAvg
        case 1:
            colorLabel.text = "blue"
            targetColor = blueAvg
        case 2:
            colorLabel.text = "yellow"
            targetColor = yellowAvg
        default:
            print("Color error")
        }
    }
}
