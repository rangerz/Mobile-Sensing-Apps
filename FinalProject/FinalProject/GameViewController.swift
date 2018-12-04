//
//  GameViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // Notification when game is over
    static let notificationName = Notification.Name("gameWon")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        // Listen to notification when game is won
        NotificationCenter.default.addObserver(self, selector: #selector(onWinGame(notification:)), name: GameViewController.notificationName, object: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // Notification received to turn off alarm and close modal
    @objc func onWinGame(notification:Notification) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: AlarmOnViewController.notificationName, object: nil)
        })
    }
}

