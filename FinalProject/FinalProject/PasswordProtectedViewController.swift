//
//  PasswordProtectedViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/4/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit

class PasswordProtectedViewController: UIViewController {
    
    @IBOutlet weak var advanceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        advanceButton.layer.cornerRadius = 8
    }
    
    @IBAction func handleInputChange(_ sender: UITextField) {
        if let pass = sender.text {
            if pass == "223344" {
                advanceButton.isHidden = false
            }
        }
    }
    
}
