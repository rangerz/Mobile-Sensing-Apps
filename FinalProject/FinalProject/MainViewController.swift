//
//  Main1ViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/2/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var alarmCollection: UICollectionView!
    @IBOutlet weak var newButton: UIButton!
    
    var dataSource = Alarms.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newButton.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollection()
    }
    
    func reloadCollection() {
        // Get new data from DB
        dataSource.refreshData()
        // Reload data in collection view
        self.alarmCollection.reloadData()
    }
}

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
