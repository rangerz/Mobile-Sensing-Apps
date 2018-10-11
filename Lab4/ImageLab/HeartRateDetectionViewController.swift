//
//  HeartRateDetectionViewController.swift
//  ImageLab
//
//  Created by Ranger on 10/7/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

class HeartRateDetectionViewController: GLKViewController   {

    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    let bridge = OpenCVBridgeSub()
    let secondsPerBuffer:Int32 = 4
    let FPS_RATE:Int32 = 30
    lazy var BUFFER_SIZE:Int32 = FPS_RATE * secondsPerBuffer
    lazy var graphHelper = SMUGraphHelper(controller: self, preferredFramesPerSecond: FPS_RATE, numGraphs: 1, plotStyle: PlotStyleSeparated, maxPointsPerGraph: BUFFER_SIZE)
    lazy var peakFinder = PeakFinder(frequencyResolution: 1)
    lazy var redValues = UnsafeMutablePointer<Float>.allocate(capacity: Int(BUFFER_SIZE))
    var counter = 0

    var keepTime: Date! = Date()
    var prevStatus = false
    var changed = false
    @IBOutlet weak var beatsLabel: UILabel!
    
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
        self.videoManager.setFPS(desiredFrameRate: 30.0)

        if !videoManager.isRunning{
            videoManager.start()
        }
        
        self.graphHelper?.setFullScreenBounds()
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

        var red:Float! = 0.0
        var green:Float! = 0.0
        var blue:Float! = 0.0
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
                changed = true
                keepTime = Date()
            }
        } else {
            keepTime = Date()
        }
        
        
        // turn on or off light
        DispatchQueue.main.async {
            if self.changed {
                if self.prevStatus {
                    _ = self.videoManager.turnOnFlashwithLevel(1.0)
                    self.beatsLabel.text = "Getting data..."
                } else {
                    self.videoManager.turnOffFlash()
                    self.beatsLabel.text = "Cover camera with your finger"
                    self.resetData()
                }
                self.changed = false
            }
        }

        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        
        if isCovered {
            self.analyzeHeartRate(red: red)
        }

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
    
    func resetData() {
        self.counter = 0
        for i in 0...Int(self.BUFFER_SIZE) - 1 {
            self.redValues[i] = 0
        }
        self.graphHelper?.setGraphData(self.redValues, withDataLength: self.BUFFER_SIZE, forGraphIndex: 0)
    }
    
    // MARK: Analyze heart beats
    func analyzeHeartRate(red: Float) {
        // Parse red to 1.0 scale
        let redThreshold:Float = 0.983
        let parsedRed:Float = red / 256
        if self.counter == 0 && parsedRed < redThreshold {
             return
        }
        
        if self.counter < self.BUFFER_SIZE {
            self.redValues[counter] = parsedRed
            self.counter = self.counter + 1
        } else {
            let peaks = self.peakFinder?.getFundamentalPeaks(fromBuffer: self.redValues, withLength: UInt(self.BUFFER_SIZE), usingWindowSize: UInt(self.BUFFER_SIZE / 5), andPeakMagnitudeMinimum: 0, aboveFrequency: 1)
            if peaks != nil {
                let peak:Peak = peaks![0] as! Peak
                print("Peaks found \(String(describing: peaks!.count))-\(peak.magnitude)")
                
                // Print bpm
                let peakCount = peaks!.count + 1
                let bpm = peakCount * Int(60/self.secondsPerBuffer)
                DispatchQueue.main.async {
                    self.beatsLabel.text = "BPM: \(bpm)"
                }
            } else {
                print("Peaks nil")
            }
            self.graphHelper?.setGraphData(self.redValues, withDataLength: self.BUFFER_SIZE, forGraphIndex: 0, withNormalization: 1.0, withZeroValue: redThreshold)
//            for i in 0...self.BUFFER_SIZE - 1 {
//                print("\(self.redValues[i])")
//            }
            self.counter = 0
        }
    }
    
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.graphHelper?.draw()
    }
}

