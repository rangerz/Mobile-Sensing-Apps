//
//  AlarmCollectionViewCell.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/2/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit

class AlarmCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var contView: UIView!
    
    var dataSource = Alarms.sharedInstance
    var mainCtrl = MainViewController()
    
    var index: Int = -1
    
    var gradientLayer: CAGradientLayer!
    var gradients = [
        [UIColor.init(rgbColorCodeRed: 21, green: 142, blue: 243, alpha: 0.9).cgColor,
        UIColor.init(rgbColorCodeRed: 38, green: 213, blue: 252, alpha: 0.5).cgColor],
        [UIColor.init(rgbColorCodeRed: 221, green: 53, blue: 26, alpha: 0.9).cgColor,
         UIColor.init(rgbColorCodeRed: 253, green: 131, blue: 131, alpha: 0.5).cgColor],
        [UIColor.init(rgbColorCodeRed: 221, green: 26, blue: 74, alpha: 0.9).cgColor,
         UIColor.init(rgbColorCodeRed: 253, green: 131, blue: 169, alpha: 0.5).cgColor],
        [UIColor.init(rgbColorCodeRed: 114, green: 26, blue: 221, alpha: 0.9).cgColor,
         UIColor.init(rgbColorCodeRed: 196, green: 131, blue: 253, alpha: 0.5).cgColor],
        [UIColor.init(rgbColorCodeRed: 221, green: 26, blue: 139, alpha: 0.9).cgColor,
         UIColor.init(rgbColorCodeRed: 253, green: 131, blue: 243, alpha: 0.5).cgColor],
    ]
    
    func setAlarm(alarm: AlarmModel, index: Int) {
        // Set labels
        timeLabel.text = alarm.time
        dateLabel.text = alarm.date
        // Save index from context to delete if necessary
        self.index = index
        // Add gradient
        createGradientLayer(index: index)
    }
    
    func createGradientLayer(index: Int) {
        // Create gradient
        gradientLayer = CAGradientLayer()
        // Set bounds with container view
        gradientLayer.frame = bgView.bounds
        // Set gradient colors with gradients array
        gradientLayer.colors = gradients[index % gradients.count]
        // Set gradient direction
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        // Set border radius
        gradientLayer.cornerRadius = 8
        // Add gradient to view
        bgView.layer.addSublayer(gradientLayer)
        // Set content view transparent to allow gradient to show
        contView.backgroundColor = UIColor(white: 1, alpha: 0)
        // Set text color
        timeLabel.textColor = UIColor(white: 1, alpha: 1)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.7)
        // Bring content to the front
        bgView.bringSubviewToFront(contView)
    }
    
    @IBAction func handleDelete(_ sender: UIButton) {
        deleteAlarm()
    }
    
    func deleteAlarm() {
        if dataSource.deleteItem(index: self.index) {
            if let mainViewController = parentViewController as? MainViewController {
                // Reload data in collection view from main controller
                mainViewController.reloadCollection()
            }
        }
    }
}

extension UIColor {
    // Utility to use 255 range in RGB
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255

        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
    }
}
