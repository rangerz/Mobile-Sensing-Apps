//
//  RunningChallengeViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import CoreMotion

class RunningChallengeViewController: UIViewController {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    let activityManager = CMMotionActivityManager()
    let alarmViewController = AlarmOnViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        mainLabel.text = "Run\nto\nturn\nalarm\noff"
        startActivityMonitoring()
    }
    
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and turn off alarm
                if let unwrappedActivity = activity {
                    if unwrappedActivity.walking {
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: AlarmOnViewController.notificationName, object: nil)
                        })
                    }
                }
            }
        }
        
    }
}
