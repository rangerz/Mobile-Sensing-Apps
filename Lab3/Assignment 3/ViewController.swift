//
//  ViewController.swift
//  Assignment 3
//
//  Created by Alejandro Henkel on 9/24/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import CoreMotion

// Taken from https://stackoverflow.com/a/20158940/3911467
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var todayStepsLabel: UILabel!
    @IBOutlet weak var yesterdayStepsLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var currentStatusImage: UIImageView!
    @IBOutlet weak var goalStepsSlider: UISlider!
    @IBOutlet weak var goalStepsLabel: UILabel!
    @IBOutlet weak var goalMissingStepsLabel: UILabel!
    @IBOutlet weak var gameButton: UIButton!
    
    
    // MARK: ======Class Variables======
    let pedometer = CMPedometer()
    let activityManager = CMMotionActivityManager()
    lazy var todaySteps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        // Load steps goal
        let defaults = UserDefaults.standard
        let steps = defaults.integer(forKey: "goalSteps")
        if steps > 0 {
            updateGoalSteps(goalSteps: steps)
            self.goalStepsSlider.value = Float(steps)
        } else {
            updateGoalSteps(goalSteps: 5000)
        }
    }
    
    // MARK: =====Motion Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and dispaly
                if let unwrappedActivity = activity {
                    if unwrappedActivity.unknown {
                        self.currentActivityLabel.text = "Unknown"
                        self.currentStatusImage.image = UIImage(named:"unknown")
                    } else if unwrappedActivity.stationary {
                        self.currentActivityLabel.text = "Still"
                        self.currentStatusImage.image = UIImage(named:"still")
                    } else if unwrappedActivity.walking {
                        self.currentActivityLabel.text = "Walking"
                        self.currentStatusImage.image = UIImage(named:"walking")
                    } else if unwrappedActivity.running {
                        self.currentActivityLabel.text = "Running"
                        self.currentStatusImage.image = UIImage(named:"running")
                    } else if unwrappedActivity.cycling {
                        self.currentActivityLabel.text = "Cycling"
                        self.currentStatusImage.image = UIImage(named:"cycling")
                    } else if unwrappedActivity.automotive {
                        self.currentActivityLabel.text = "Driving"
                        self.currentStatusImage.image = UIImage(named:"driving")
                    }
                }
            }
        }
        
    }
    
    func startPedometerMonitoring(){
        let endOfToday = Date()
        let endOfYesterday = Calendar.current.date(byAdding: .day, value:-1, to: endOfToday)?.endOfDay
        let startOfToday = endOfToday.startOfDay
        let startOfYesterday = endOfYesterday?.startOfDay
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .full
//        dateFormatter.timeStyle = .full
//        print("\(dateFormatter.string(from: endOfToday)) \(dateFormatter.string(from: startOfToday))")
//        print("\(dateFormatter.string(from: endOfYesterday!)) \(dateFormatter.string(from: startOfYesterday!))")
        
        if CMPedometer.isStepCountingAvailable(){
            // Today steps are populated first with a query
            self.pedometer.queryPedometerData(from: startOfToday, to: endOfToday, withHandler: { (pedData, error) in
                if let unwrappedData = pedData {
                    DispatchQueue.main.async {
                        self.updateTodaySteps(steps: Int(truncating: unwrappedData.numberOfSteps))
                    }
                }
            })
            
            // Populate yesterday steps
            self.pedometer.queryPedometerData(from: startOfYesterday!, to: endOfYesterday!, withHandler: { (pedData, error) in
                if let unwrappedData = pedData {
                    DispatchQueue.main.async {
                        self.yesterdayStepsLabel.text = "\(unwrappedData.numberOfSteps)" //"\(unwrappedData.numberOfSteps) steps"
                    }
                }
            })
            
            // Start monitoring current steps
            pedometer.startUpdates(from: startOfToday)
            {(pedData:CMPedometerData?, error:Error?)->Void in
                if pedData != nil {
                    DispatchQueue.main.async {
                        self.updateTodaySteps(steps: Int(truncating: pedData!.numberOfSteps))
                    }
                }
            }
        }
    }
    
    // MARK: =====Slider methods=====
    @IBAction func goalStepsChanged(_ sender: UISlider) {
        updateGoalSteps(goalSteps: Int(ceil(sender.value)))
        updateMissingGoalSteps(currentSteps: self.todaySteps)
    }
    
    func updateGoalSteps(goalSteps:Int) {
        let defaults = UserDefaults.standard
        defaults.set(goalSteps, forKey: "goalSteps")
        
        self.goalStepsLabel.text = "\(goalSteps) steps"
    }
    
    func updateMissingGoalSteps(currentSteps: Int) {
        self.todaySteps = currentSteps
        let defaults = UserDefaults.standard
        let goalSteps = defaults.integer(forKey: "goalSteps")
        
        if goalSteps > 0 {
            let missingSteps = goalSteps - currentSteps
            if missingSteps <= 0 {
                self.goalMissingStepsLabel.text = "Congratulations! You've reached your goal"
                self.gameButton.isHidden = false
            } else {
                self.goalMissingStepsLabel.text = "\(missingSteps) steps"
                self.gameButton.isHidden = true
            }

            if (goalSteps < currentSteps*2) {
                bonusMode = true
                self.gameButton.setTitle("Play Game (Bonus Mode) 🏆", for: .normal)
            } else {
                bonusMode = false
                self.gameButton.setTitle("Play Game 🎱", for: .normal)
            }
        }
    }

    func updateTodaySteps(steps:Int) {
        self.todaySteps = steps
        self.todayStepsLabel.text = "\(steps)" //"\(steps) steps"
        self.updateMissingGoalSteps(currentSteps: steps)
    }
}

