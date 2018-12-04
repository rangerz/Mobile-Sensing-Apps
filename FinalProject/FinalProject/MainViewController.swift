//
//  Main1ViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/2/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import UserNotifications

class MainViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var alarmCollection: UICollectionView!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var dataSource = Alarms.sharedInstance
    var soundManager = SoundManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newButton.layer.cornerRadius = 8
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollection()
    }
    
    func reloadCollection() {
        // Get new data from DB
        dataSource.refreshData()
        
        if dataSource.alarms.count == 0 {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
        
        // Reload data in collection view
        self.alarmCollection.reloadData()
    }
    
    // MARK: Notifications
    // Allow in-app notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Allow alert and sound on in-app notifications
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let items: [String] = response.notification.request.identifier.components(separatedBy: "-")
        // Get alarm index and try to remove it
        let alarmIndex = Int(items[1])!
        let _ = dataSource.deleteItem(index: alarmIndex, removeNotification: false)
        
        // Get alarm name index and play it again
        let alarmNameIndex = Int(items[2])!
        soundManager.startAlarm(index: alarmNameIndex)
        
        // Present new view controller
        let modalVC: AlarmOnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlarmOnViewController") as UIViewController as! AlarmOnViewController
        self.present(modalVC, animated: false, completion: nil)
    }
    
}

// Handle collection view with alarms list
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.alarms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let alarm = dataSource.alarms[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlarmCollectionCell", for: indexPath) as! AlarmCollectionViewCell
        cell.setAlarm(alarm: alarm, index: indexPath.row)
        return cell
    }
}

extension UIView {
    // Add acces to parent ViewController in every view
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
