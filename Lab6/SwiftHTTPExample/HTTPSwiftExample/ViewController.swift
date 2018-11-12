//
//  ViewController.swift
//  HTTPSwiftExample
//
//  Created by Eric Larson on 3/30/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

// This exampe is meant to be run with the python example:
//              tornado_example.py 
//              from the course GitHub repository: tornado_bare, branch sklearn_example

import UIKit
import CoreMotion

class ViewController: UIViewController, URLSessionDelegate {
    
    // MARK: Class Properties
    var session = URLSession()
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    
    var ringBuffer = RingBuffer()
    var JSON = JSONUtilities()
    let animation = CATransition()
    let motion = CMMotionManager()
    
    var magValue = 0.5
    var isCalibrating = false
    var dsid:Int = 2
    var currentAlgorithm = 0
    
    var isWaitingForMotionData = false
    
    @IBOutlet weak var paramSlider: UISlider!
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var paramValue: UILabel!
    @IBOutlet weak var awayArrow: UILabel!
    @IBOutlet weak var rightArrow: UILabel!
    @IBOutlet weak var towardsArrow: UILabel!
    @IBOutlet weak var leftArrow: UILabel!
    @IBOutlet weak var largeMotionMagnitude: UIProgressView!

    // MARK: Class Properties with Observers
    enum CalibrationStage {
        case notCalibrating
        case away
        case right
        case towards
        case left
    }
    
    var calibrationStage:CalibrationStage = .notCalibrating {
        didSet{
            switch calibrationStage {
            case .away:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.setAsCalibrating(self.awayArrow)
                    self.setAsNormal(self.rightArrow)
                    self.setAsNormal(self.leftArrow)
                    self.setAsNormal(self.towardsArrow)
                }
                break
            case .left:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.setAsNormal(self.awayArrow)
                    self.setAsNormal(self.rightArrow)
                    self.setAsCalibrating(self.leftArrow)
                    self.setAsNormal(self.towardsArrow)
                }
                break
            case .towards:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.setAsNormal(self.awayArrow)
                    self.setAsNormal(self.rightArrow)
                    self.setAsNormal(self.leftArrow)
                    self.setAsCalibrating(self.towardsArrow)
                }
                break
                
            case .right:
                self.isCalibrating = true
                DispatchQueue.main.async{
                    self.setAsNormal(self.awayArrow)
                    self.setAsCalibrating(self.rightArrow)
                    self.setAsNormal(self.leftArrow)
                    self.setAsNormal(self.towardsArrow)
                }
                break
            case .notCalibrating:
                self.isCalibrating = false
                DispatchQueue.main.async{
                    self.setAsNormal(self.awayArrow)
                    self.setAsNormal(self.rightArrow)
                    self.setAsNormal(self.leftArrow)
                    self.setAsNormal(self.towardsArrow)
                }
                break
            }
        }
    }

    // MARK: Core Motion Updates
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            let mag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            
            DispatchQueue.main.async{
                //show magnitude via indicator
                self.largeMotionMagnitude.progress = Float(mag)/0.2
            }
            
            if mag > self.magValue {
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.calibrationOperationQueue.addOperation {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                    }
                })
            }
        }
    }
    
    
    //MARK: Calibration procedure
    func largeMotionEventOccurred(){
        if(self.isCalibrating){
            //send a labeled example
            if(self.calibrationStage != .notCalibrating && self.isWaitingForMotionData)
            {
                self.isWaitingForMotionData = false
                
                // send data to the server with label
                sendFeatures(self.ringBuffer.getDataAsVector(),
                             withLabel: self.calibrationStage)
                
                self.nextCalibrationStage()
            }
        }
    }
    
    func nextCalibrationStage(){
        switch self.calibrationStage {
        case .notCalibrating:
            //start with away arrow
            self.calibrationStage = .away
            setDelayedWaitingToTrue(1.0)
            break
        case .away:
            //go to right arrow
            self.calibrationStage = .right
            setDelayedWaitingToTrue(1.0)
            break
        case .right:
            //go to towards arrow
            self.calibrationStage = .towards
            setDelayedWaitingToTrue(1.0)
            break
        case .towards:
            //go to left arrow
            self.calibrationStage = .left
            setDelayedWaitingToTrue(1.0)
            break
            
        case .left:
            //end calibration
            self.calibrationStage = .notCalibrating
            setDelayedWaitingToTrue(1.0)
            break
        }
    }
    
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    
    func setAsCalibrating(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.backgroundColor = UIColor.red
    }
    
    func setAsNormal(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.backgroundColor = UIColor.white
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.



        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = 0.5
        
        dsid = 2 // set this and it will update UI
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // setup core motion handlers
        startMotionUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.motion.isDeviceMotionAvailable {
            self.motion.stopDeviceMotionUpdates()
        }
    }
    
    //MARK: Calibration
    @IBAction func startCalibration(_ sender: AnyObject) {
        self.isWaitingForMotionData = false // dont do anything yet
        nextCalibrationStage()
        
    }
    
    //MARK: Comm with Server
    func sendFeatures(_ array:[Double], withLabel label:CalibrationStage){
        let baseURL = "\(SERVER_URL)/AddDataPoint"
        let postUrl = URL(string: "\(baseURL)")

        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        request.setValue(COOKIE_SECRET, forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array,
                                       "label":"\(label)",
                                       "dsid":self.dsid]
        
        
        let requestBody:Data? = JSON.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.JSON.convertDataToDictionary(with: data)
                    
                    print(jsonDictionary["feature"]!)
                    print(jsonDictionary["label"]!)
                }
        })
        
        postTask.resume() // start the task
    }
    
    func blinkLabel(_ label:UILabel){
        DispatchQueue.main.async {
            self.setAsCalibrating(label)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setAsNormal(label)
            })
        }
        
    }

    func getAlgorithm() -> String {
        switch self.currentAlgorithm {
        case 0:
            return "KNN"
        case 1:
            return "SVM"
        default:
            return "RF"
        }
    }
    
    func getHelpLabel() {
        switch self.currentAlgorithm {
        case 0:
            self.paramLabel.text = "Select the number of neighbors"
            self.paramSlider.minimumValue = 1
            self.paramSlider.maximumValue = 10
            self.paramSlider.value = 3
            self.paramValue.text = "3"
        case 1:
            self.paramLabel.text = "Select alpha"
            self.paramSlider.minimumValue = 0
            self.paramSlider.maximumValue = 4
            self.paramSlider.value = 3
            self.paramValue.text = "0.0001"
        default:
            self.paramLabel.text = "Select the number of estimators"
            self.paramSlider.minimumValue = 1
            self.paramSlider.maximumValue = 200
            self.paramSlider.value = 100
            self.paramValue.text = "100"
        }
    }
    
    @IBAction func onAlgorithmChange(_ sender: UISegmentedControl) {
        self.currentAlgorithm = sender.selectedSegmentIndex
        getHelpLabel()
    }
    
    @IBAction func onParamChange(_ sender: UISlider) {
        switch self.currentAlgorithm {
        case 0:
            self.paramValue.text = "\(Int(sender.value))"
        case 1:
            var number = "0."
            if (Int(sender.value) > 0) {
                for _ in 1...Int(sender.value) {
                    number.append("0")
                }
            }
            self.paramValue.text = "\(number)1"
        default:
            self.paramValue.text = "\(Int(sender.value))"
        }
    }
    
    @IBAction func makeModel(_ sender: AnyObject) {
        
        // create a GET request for server to update the ML model with current data
        let baseURL = "\(SERVER_URL)/UpdateModel"
        let query = "?dsid=\(self.dsid)&type=\(self.getAlgorithm())&param=\(self.paramValue.text!)"
        // type support KNN, SVM, and RF
        
        let getUrl = URL(string: baseURL+query)
        var request: URLRequest = URLRequest(url: getUrl!)
        request.setValue(COOKIE_SECRET, forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
              completionHandler:{(data, response, error) in
                // handle error!
                if (error != nil) {
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.JSON.convertDataToDictionary(with: data)
                    
                    if let resubAcc = jsonDictionary["resubAccuracy"]{
                        print("Resubstitution Accuracy is", resubAcc)
                    }
                }
                                                                    
        })
        
        dataTask.resume() // start the task
        
    }
}





