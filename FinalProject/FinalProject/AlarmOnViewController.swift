//
//  AlarmOnViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit

class AlarmOnViewController: UIViewController {
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var turnOffButton: UIButton!
    
    static let notificationName = Notification.Name("alarmTurnedOff")
    var soundSource = SoundManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set UI
        bigLabel.text = "Time\nto\nwake\nup!!"
        turnOffButton.layer.cornerRadius = 8;
        
        // Listen to notification and call turn off alarm
        NotificationCenter.default.addObserver(self, selector: #selector(onTurnOffAlarm(notification:)), name: AlarmOnViewController.notificationName, object: nil)
    }
    
    @IBAction func handleTurnOff(_ sender: UIButton) {
        handleChallenges()
    }
    
    func handleChallenges() {
        // Pick a random challenge
        let challengeNumber = Int.random(in: 0 ..< 2)
//        let challengeNumber = 1
        
        // Variables to open next view controller
        var modalChallenge: UIViewController?
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Select challenge
        switch challengeNumber {
        case 0:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "RunningChallengeViewController") as UIViewController as! RunningChallengeViewController
        case 1:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "MLChallengeViewController") as UIViewController as! MLChallengeViewController
        default:
            print("Challenge error")
        }
        // Open new challenge
        self.present(modalChallenge!, animated: false, completion: nil)
    }
    
    // Notification received to turn off alarm and close modal
    @objc func onTurnOffAlarm(notification:Notification) {
        soundSource.stopAlarm()
        self.dismiss(animated: false, completion: nil)
    }
}
