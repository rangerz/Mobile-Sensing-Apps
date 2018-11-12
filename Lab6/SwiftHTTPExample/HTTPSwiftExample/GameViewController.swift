//
//  GameViewController.swift
//  HTTPSwiftExample
//
//  Created by Alejandro Henkel on 11/11/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

import UIKit
import CoreMotion

class GameViewController: UIViewController, URLSessionDelegate {
    // MARK: Class Properties
    var session = URLSession()
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()

    var isWaitingForAnswer = false
    
    var ringBuffer = RingBuffer()
    var JSON = JSONUtilities()
    let animation = CATransition()
    let motion = CMMotionManager()

    var magValue = 0.5
    var dsid:Int = 2
    var currentDirection = ""
    
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var failLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var predictingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        newRound()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.motion.isDeviceMotionAvailable {
            self.motion.stopDeviceMotionUpdates()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // setup core motion handlers
        startMotionUpdates()
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
        if(self.isWaitingForAnswer)
        {
            DispatchQueue.main.async {
                self.predictingLabel.isHidden = false
            }
            self.isWaitingForAnswer = false
            //predict a label
            getPrediction(self.ringBuffer.getDataAsVector())
            // dont predict again for a bit
            changeRoundDelayed(3.0)
            
        }
    }
    
    func getPrediction(_ array:[Double]){
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        request.setValue(COOKIE_SECRET, forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array, "dsid":self.dsid]
        
        
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
                                                                        
                                                                        let labelResponse = jsonDictionary["prediction"]!
                                                                        print(labelResponse)
                                                                        self.compareAnswer(labelResponse as! String)
                                                                    }
        })
        
        postTask.resume() // start the task
    }
    
    
    func newRound() {
        let direction = getRandomDirection()
        self.currentDirection = direction
        indicatorLabel.text = getIndicatorLabel(direction: direction)
        failLabel.isHidden = true
        correctLabel.isHidden = true
        isWaitingForAnswer = true
    }
    
    func compareAnswer(_ response:String){
        DispatchQueue.main.async {
            self.predictingLabel.isHidden = true
            if ("['\(self.currentDirection)']" == response) {
                self.correctLabel.isHidden = false
            } else {
                self.failLabel.isHidden = false
            }
        }
    }
    
    // MARK: Utilities
    func getRandomDirection() -> String {
        let number = Int.random(in: 1 ... 4)
        switch number {
        case 1:
            return "left"
        case 2:
            return "right"
        case 3:
            return "towards"
        default:
            return "away"
        }
    }
    
    func getIndicatorLabel(direction: String) -> String {
        let directions = ["left": "LEFT", "right": "RIGHT", "towards": "TOWARDS YOU", "away": "AWAY FROM YOU"]
        return directions[direction]!
    }
    
    func changeRoundDelayed(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.newRound()
        })
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
