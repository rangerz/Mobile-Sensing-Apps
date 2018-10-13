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
    var videoManager:VideoAnalgesic! = nil
    var detector:CIDetector! = nil
    let bridge = OpenCVBridgeSub()
    let DETECT_SEC:Int32 = 7
    let FPS_RATE:Int32 = 30
    lazy var BUFFER_SIZE:Int32 = FPS_RATE * DETECT_SEC
    lazy var graphHelper = SMUGraphHelper(controller: self, preferredFramesPerSecond: FPS_RATE, numGraphs: 1, plotStyle: PlotStyleSeparated, maxPointsPerGraph: BUFFER_SIZE)
    var peakFinder = PeakFinder(frequencyResolution: 1)
    lazy var inputBuf = UnsafeMutablePointer<Float>.allocate(capacity: Int(1))
    lazy var drawBuf = UnsafeMutablePointer<Float>.allocate(capacity: Int(BUFFER_SIZE))
    lazy var buffer = CircularBuffer(numChannels: 1, andBufferSize: Int64(BUFFER_SIZE))
    var prevBpm:Float = 0.0
    var keepTime: Date! = Date()
    var prevStatus: Bool! = false
    var changed = false
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!

    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = nil

        self.bridge.loadHaarCascade(withFilename: "nose")

        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
//        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        self.updateDescription()

        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]

        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))

        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        self.videoManager.setFPS(desiredFrameRate: Double(FPS_RATE))

        if !videoManager.isRunning{
            videoManager.start()
        }
        
        self.graphHelper?.setBoundsWithTop(0 , bottom: -1, left: -0.95, right: 0.95)
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
        var isDetect = false
        var red:Float! = 0.0
        var green:Float! = 0.0
        var blue:Float! = 0.0

        // detect finger
        if AVCaptureDevice.Position.back == self.videoManager.getCameraPostion() {
            self.bridge.setTransforms(self.videoManager.transform)
            self.bridge.setImage(retImage,
                                 withBounds: retImage.extent, // the first face bounds
                andContext: self.videoManager.getCIContext())
            self.bridge.getColorMean(&red, withGreen:&green, andBlue:&blue)
            retImage = self.bridge.getImageComposite()
            let isCovered = checkCovered(red:red, green:green, blue:blue)

            // turn on or off light
            DispatchQueue.main.async {
                if self.changed {
                    if isCovered {
                        _ = self.videoManager.turnOnFlashwithLevel(1.0)
                    } else {
                        self.videoManager.turnOffFlash()
                    }
                    self.changed = false
                }
            }

            isDetect = isCovered
        } else { // detect face
            let f = getFaces(img: inputImage)
            retImage = inputImage

            if f.count == 1 {
                isDetect = true
                self.bridge.setTransforms(self.videoManager.transform)
                self.bridge.setImage(retImage,
                                     withBounds: f[0].bounds, // the first face bounds
                    andContext: self.videoManager.getCIContext())
                self.bridge.getColorMean(&red, withGreen:&green, andBlue:&blue)
                retImage = self.bridge.getImageComposite()
            }
        }

        if isDetect {
            self.analyzeHeartRate(red: red)
        } else {
            self.resetData()
        }

        return retImage
    }

    func checkCovered(red: Float, green: Float, blue: Float) -> Bool{
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

        return prevStatus
    }

    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
    }
    
    func resetData() {
        prevBpm = 0
        buffer?.clear()
        buffer?.fetchFreshData(drawBuf, withNumSamples: Int64(BUFFER_SIZE))
        self.graphHelper?.setGraphData(drawBuf,
                                       withDataLength: self.BUFFER_SIZE,
                                       forGraphIndex: 0)
        DispatchQueue.main.async {
            self.bpmLabel.text = "BPM: no data"
        }
    }

    // MARK: Calc Heart Rate
    func getHeartRate(peaks:Array<Peak>)->Float {
        var bpm:Float = 0.0
        var totalDiff:Float = 0.0
        var diffCount = 0

        if 2 <= peaks.count {
            let sortedPeaks = peaks.sorted(by: { $0.frequency > $1.frequency })

            for index in 0...sortedPeaks.count-2 {
                let peak:Peak = peaks[index]
                let diff = peak.frequency - sortedPeaks[index+1].frequency

//                NSLog("[%d]Diff = %f", index, diff)
                //pick available peak diff value (range in 60 ~ 150 bpm)
                if diff >= 12 && diff <= 30 {
                    totalDiff = totalDiff + diff
                    diffCount = diffCount + 1
                }
            }
        }

        if 0 < diffCount {
            let avgDiff:Float = totalDiff / Float(diffCount)
            bpm = Float(60) * Float(FPS_RATE) / avgDiff
        }

        if 0 != bpm {
//            NSLog("update bpm = %f", bpm)
            if 0 == prevBpm {
                prevBpm = bpm
            } else {
                prevBpm = (bpm + prevBpm*29) / 30
            }
        }

        return prevBpm;
    }

    // MARK: Analyze heart beats
    func analyzeHeartRate(red: Float) {
        let redThreshold:Float = 0.983
        var bpm:Float = 0.0
        // Parse red to 1.0 scale
        let parsedRed:Float = red / 256

        inputBuf[0] = parsedRed
        buffer?.addNewFloatData(inputBuf, withNumSamples: 1)

        buffer?.fetchFreshData(drawBuf, withNumSamples: Int64(BUFFER_SIZE))
        let numData = Int(buffer?.numUnreadFrames() ?? 0)

        if BUFFER_SIZE <= numData {
            do {
                // Avoid crash here ...
                guard let peaks:Array<Peak> = try self.peakFinder?.getFundamentalPeaks(
                    fromBuffer: drawBuf,
                    withLength: UInt(self.BUFFER_SIZE),
                    usingWindowSize: UInt(self.BUFFER_SIZE / 5),
                    andPeakMagnitudeMinimum: 0,
                    aboveFrequency: 1
                    ) as? Array<Peak> else {
                        return
                }

                bpm = getHeartRate(peaks: peaks)
            } catch {
            }

            if 0 != bpm {
                DispatchQueue.main.async {
                    self.bpmLabel.text = "BPM: \(Int(bpm))"
                }
            }
        }

        if 0 == prevBpm {
            DispatchQueue.main.async {
                let sec = Calendar.current.component(.second, from: Date());
                let dot = String(repeating: ".", count: sec % 3 + 1)
                self.bpmLabel.text = "BPM: Detecting" + dot
            }
        }

        self.graphHelper?.setGraphData(drawBuf,
                                       withDataLength: self.BUFFER_SIZE,
                                       forGraphIndex: 0,
                                       withNormalization: 1.0,
                                       withZeroValue: redThreshold)
    }

    func updateDescription() {
        DispatchQueue.main.async {
            if AVCaptureDevice.Position.back == self.videoManager.getCameraPostion() {
                self.descriptionLabel.text = "Cover camera with your finger"
            } else {
                self.descriptionLabel.text = "Look camera with your face"
            }
        }
    }

    @IBAction func switchCamera(_ sender: Any) {
        self.videoManager.toggleCameraPosition()
        self.updateDescription()
        self.resetData()
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.graphHelper?.draw()
    }
}

