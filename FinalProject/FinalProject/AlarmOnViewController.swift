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
    var videoManager = VideoAnalgesic.sharedInstance
    
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
        let challengeNumber = Int.random(in: 0 ..< 5)
        
        // Variables to open next view controller
        var modalChallenge: UIViewController?
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Select challenge
        switch challengeNumber {
        case 0:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "RunningChallengeViewController") as UIViewController as! RunningChallengeViewController
        case 1:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "MLChallengeViewController") as UIViewController as! MLChallengeViewController
        case 2:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "FaceDetectorChallengeViewController") as UIViewController as! FaceDetectorChallengeViewController
        case 3:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "GameChallengeViewController") as UIViewController as! GameViewController
        case 4:
            modalChallenge = storyboard.instantiateViewController(withIdentifier: "ColorChallengeViewController") as UIViewController as! ColorChallengeViewController
        default:
            print("Challenge error")
        }
        // Open new challenge
        self.present(modalChallenge!, animated: false, completion: nil)
    }
    
    // Notification received to turn off alarm and close modal
    @objc func onTurnOffAlarm(notification:Notification) {
        // Stop alarm
        soundSource.stopAlarm()
        // Make sure video is off
        videoManager.stop()
        videoManager.shutdown()
        // Close modal
        self.dismiss(animated: false, completion: nil)
    }
}
