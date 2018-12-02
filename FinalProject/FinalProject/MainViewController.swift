//
//  Main1ViewController.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/2/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var dataSource = Alarms.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.alarms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let alarm = dataSource.alarms[indexPath.row]
//        let cell = collectionView.dequeueReusableCell(withIdentifier: "AlarmCell") as! AlarmCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlarmCollectionCell", for: indexPath) as! AlarmCollectionViewCell
        cell.setAlarm(alarm: alarm, index: indexPath.row)
        return cell
    }
}
