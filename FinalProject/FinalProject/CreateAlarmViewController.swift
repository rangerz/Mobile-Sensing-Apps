//
//  CreateAlarmViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/1/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import CoreData

class CreateAlarmViewController: UIViewController {

    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    var dataSource = Alarms.sharedInstance
    var mainController = MainViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set min date to current date
        picker.minimumDate = Date()
        saveButton.layer.cornerRadius = 8
    }
    
    @IBAction func handleSave(_ sender: UIButton) {
        save(date: picker.date)
    }
    
    func save(date: Date) {
        // Save data and pop view
        if dataSource.save(date: date) {
            closeView()
        }
    }
    
    func closeView() {
        navigationController?.popViewController(animated: true)
    }
}
