//
//  VFaceDetectionViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

struct FaceStatus : OptionSet {
    let rawValue: Int

    static let noFace  = FaceStatus(rawValue: -1)
    static let pokerFace  = FaceStatus(rawValue: 0)
    static let smileMouth = FaceStatus(rawValue: 1 << 0)
    static let blinkLeftEye = FaceStatus(rawValue: 1 << 1)
    static let blinkRightEye = FaceStatus(rawValue: 1 << 2)
}

class FaceDetectionViewController: UIViewController   {

    //MARK: Class Properties
    var videoManager:VideoAnalgesic! = nil
    var detector:CIDetector! = nil
    var prevFaceStatus:FaceStatus = .noFace
    var statusUpdateTime: Date! = Date()
    @IBOutlet weak var faceStatusImage: UIImageView!
    @IBOutlet weak var mouthLabel: UILabel!
    @IBOutlet weak var blinkEyeLabel: UILabel!

    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = nil

        self.videoManager = VideoAnalgesic.sharedInstance

        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)

        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow, CIDetectorTracking:true] as [String : Any]

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

    //MARK: Apply highlight filters for multiple faces
    func highlightFaces(inputImage:CIImage,features:[CIFaceFeature])->CIImage {
        var maskImage : CIImage! = nil
        var filterCenter = CGPoint()

        // prepare mask image for each face
        for f in features {
            filterCenter.x = f.bounds.origin.x + f.bounds.size.width / 2.0
            filterCenter.y = f.bounds.origin.y + f.bounds.size.height / 2.0
            let radius = min(f.bounds.size.width, f.bounds.size.height) / 1.5

            let radialGradient: CIFilter = CIFilter(name:"CIRadialGradient")!
            radialGradient.setValue(CIVector(cgPoint: filterCenter), forKey:kCIInputCenterKey)
            radialGradient.setValue(radius, forKey:"inputRadius0")
            radialGradient.setValue(radius + 1.0, forKey:"inputRadius1")
            radialGradient.setValue(CIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), forKey:"inputColor0")
            radialGradient.setValue(CIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0), forKey:"inputColor1")
            let circleImage = radialGradient.outputImage!

            if (maskImage == nil) {
                maskImage = circleImage
            } else {
                let compositingFilter : CIFilter = CIFilter(name:"CISourceOverCompositing")!
                compositingFilter.setValue(circleImage, forKey: kCIInputImageKey)
                compositingFilter.setValue(maskImage, forKey: kCIInputBackgroundImageKey)
                maskImage = compositingFilter.outputImage
            }
        }

        // zoom blur image for background
        let blurFilter: CIFilter = CIFilter(name: "CIZoomBlur")!
        blurFilter.setValue(inputImage, forKey:kCIInputImageKey)
        let zoomBlurImage = blurFilter.outputImage

        // merge each face and background
        let blendFilter: CIFilter = CIFilter(name: "CIBlendWithMask")!
        blendFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blendFilter.setValue(zoomBlurImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(maskImage, forKey: kCIInputMaskImageKey)

        return blendFilter.outputImage!
    }

    func highlightEyesMouth(inputImage:CIImage,features:[CIFaceFeature])->CIImage {
        var retImage = inputImage

        for f in features {
            if f.hasLeftEyePosition {
                let filter : CIFilter = CIFilter(name:"CIBumpDistortion")!
                filter.setValue(retImage, forKey: "inputImage")
                filter.setValue(CIVector(cgPoint:f.leftEyePosition), forKey: "inputCenter")
                filter.setValue(20, forKey: "inputRadius")
                retImage = filter.outputImage!
            }

            if f.hasRightEyePosition {
                let filter : CIFilter = CIFilter(name:"CIBumpDistortion")!
                filter.setValue(retImage, forKey: "inputImage")
                filter.setValue(CIVector(cgPoint:f.rightEyePosition), forKey: "inputCenter")
                filter.setValue(30, forKey: "inputRadius")
                retImage = filter.outputImage!
            }

            if f.hasMouthPosition {
                let filter : CIFilter = CIFilter(name:"CIPinchDistortion")!
                filter.setValue(retImage, forKey: "inputImage")
                filter.setValue(CIVector(cgPoint:f.mouthPosition), forKey: "inputCenter")
                filter.setValue(30, forKey: "inputRadius")
                retImage = filter.outputImage!
            }
        }

        return retImage
    }

    //MARK: Apply filters and apply feature detectors
    // CoreImage filter doc: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    func applyFiltersToFaces(inputImage:CIImage,features:[CIFaceFeature])->CIImage{
        var retImage = inputImage

        retImage = highlightFaces(inputImage:retImage, features:features)

        retImage = highlightEyesMouth(inputImage:retImage, features:features)

        return retImage
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

    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        // detect faces
        let f = getFaces(img: inputImage)

        // update UI image and label
        updateFacesStatus(features: f)

        // if no faces, just return original image
        if f.count == 0 { return inputImage }

        // otherwise apply the filters to the faces
        return applyFiltersToFaces(inputImage: inputImage, features: f)
    }

    //MARK: Update Face UI Status (Image and Label)
    func updateFacesStatus(features:[CIFaceFeature]) {
        let curfaceStatus:FaceStatus = getFaceStatus(features: features)

        DispatchQueue.main.async {
            var imageUrl: String? = nil
            var mouthStatus: String? = nil
            var blinkStatus: String? = nil

            if curfaceStatus.contains(.noFace) {
                imageUrl = "no_face"
                mouthStatus = "Mouth: Detecting ..."
                blinkStatus = "Blinking Eye: Detecting ..."
            } else {
                if curfaceStatus.contains(.smileMouth) {
                    imageUrl = "smile"
                    mouthStatus = "Mouth: Simle"
                } else {
                    imageUrl = "poke"
                    mouthStatus = "Mouth: No Simle"
                }

                if curfaceStatus.contains(.blinkLeftEye) && curfaceStatus.contains(.blinkRightEye) {
                    imageUrl = imageUrl! + "_two_blink"
                    blinkStatus = "Blinking Eye: Both"
                } else if curfaceStatus.contains(.blinkLeftEye) {
                    imageUrl = imageUrl! + "_left_blink"
                    blinkStatus = "Blinking Eye: Left"
                } else if curfaceStatus.contains(.blinkRightEye) {
                    imageUrl = imageUrl! + "_right_blink"
                    blinkStatus = "Blinking Eye: Right"
                } else {
                    blinkStatus = "Blinking Eye: None"
                }
            }

            self.faceStatusImage.image = UIImage(named: imageUrl!)
            self.mouthLabel.text = mouthStatus
            self.blinkEyeLabel.text = blinkStatus
        }
    }

    func getFaceStatus(features:[CIFaceFeature]) -> FaceStatus {
        let elapsed = statusUpdateTime.timeIntervalSinceNow * -1
        var curfaceStatus:FaceStatus = .pokerFace

        if 0 == features.count {
            curfaceStatus = .noFace
        } else {
            for f in features {
                if f.hasSmile {curfaceStatus.insert(.smileMouth)}
                if f.leftEyeClosed {curfaceStatus.insert(.blinkLeftEye)}
                if f.rightEyeClosed {curfaceStatus.insert(.blinkRightEye)}
            }
        }

        if curfaceStatus != prevFaceStatus {
            if 1.5 > elapsed && !(prevFaceStatus.contains(.noFace)) {
                prevFaceStatus.insert(curfaceStatus)
            } else {
                prevFaceStatus = curfaceStatus
                statusUpdateTime = Date()
            }
        } else {
            statusUpdateTime = Date()
        }

        return prevFaceStatus
    }

    @IBAction func switchCamera(_ sender: Any) {
        self.videoManager.toggleCameraPosition()
    }
}

