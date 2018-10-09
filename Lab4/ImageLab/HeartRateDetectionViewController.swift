//
//  HeartRateDetectionViewController.swift
//  ImageLab
//
//  Created by Ranger on 10/7/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class HeartRateDetectionViewController: UIViewController   {

    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    let bridge = OpenCVBridgeSub()

    //MARK: Outlets in view
    @IBOutlet weak var flashSlider: UISlider!
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var positionButton: UIButton!
    var keepTime: Date! = Date()
    var prevStatus = false

    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = nil
        self.setupFilters()

        self.bridge.loadHaarCascade(withFilename: "nose")

        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)

        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]

        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))

        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)

        if !videoManager.isRunning{
            videoManager.start()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        if videoManager.isRunning{
            self.videoManager.turnOffFlash()
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }

    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        var retImage = inputImage

        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: retImage.extent, // the first face bounds
            andContext: self.videoManager.getCIContext())

        self.bridge.drawColorODS()

        var red:Double! = 0.0
        var green:Double! = 0.0
        var blue:Double! = 0.0
        self.bridge.getColorMean(&red, withGreen:&green, andBlue:&blue)

        // check dark or red color to set cover status
        var isCovered = false
        let maxValue = max(red, green, blue)
        if maxValue < 30 {
            if maxValue == red {
                isCovered = true
            }
        } else if red < 100 {
            if green < (red - 25) && blue < (red - 25) {
                isCovered = true
            }
        } else if red >= 100 {
            if green < (red - 50) && blue < (red - 50) {
                isCovered = true
            }
        }

        // keep light 2 second for avoiding flicker
        let elapsed = keepTime.timeIntervalSinceNow * -1
        if (prevStatus != isCovered) {
            if 2 < elapsed || isCovered {
                prevStatus = isCovered
                keepTime = Date()
            }
        } else {
            keepTime = Date()
        }

        // turn on or off light
        DispatchQueue.main.async {
            if self.prevStatus {
                self.flashButton.isEnabled = false;
                self.positionButton.isEnabled = false;
                _ = self.videoManager.turnOnFlashwithLevel(1.0)
            } else {
                self.flashButton.isEnabled = true;
                self.positionButton.isEnabled = true;
                self.videoManager.turnOffFlash()
            }
        }

        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)

        return retImage
    }

    //MARK: Setup filtering
    func setupFilters(){
        filters = []

        let filterPinch = CIFilter(name:"CIBumpDistortion")!
        filterPinch.setValue(-0.5, forKey: "inputScale")
        filterPinch.setValue(75, forKey: "inputRadius")
        filters.append(filterPinch)

    }

    //MARK: Apply filters and apply feature detectors
    func applyFiltersToFaces(inputImage:CIImage,features:[CIFaceFeature])->CIImage{
        var retImage = inputImage
        var filterCenter = CGPoint()

        for f in features {
            //set where to apply filter
            filterCenter.x = f.bounds.midX
            filterCenter.y = f.bounds.midY

            //do for each filter (assumes all filters have property, "inputCenter")
            for filt in filters{
                filt.setValue(retImage, forKey: kCIInputImageKey)
                filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                // could also manipualte the radius of the filter based on face size!
                retImage = filt.outputImage!
            }
        }
        return retImage
    }

    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        //let optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
    }

    @IBAction func swipeRecognized(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            self.bridge.processType += 1
        case UISwipeGestureRecognizerDirection.right:
            self.bridge.processType -= 1
        default:
            break

        }

        stageLabel.text = "Stage: \(self.bridge.processType)"
    }

    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(_ sender: AnyObject) {
        if(self.videoManager.toggleFlash()){
            self.flashSlider.value = 1.0
        }
        else{
            self.flashSlider.value = 0.0
        }
    }

    @IBAction func switchCamera(_ sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }

    @IBAction func setFlashLevel(sender: UISlider) {
        if(sender.value>0.0){
            _ = self.videoManager.turnOnFlashwithLevel(sender.value)
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }
}

