//
//  Alarm.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 11/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import Foundation

class AlarmModel {
    var time: String
    var date: String
    
    init(alarm: Alarm) {
        // Get time string
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        var parsedDate = formatter.string(from: alarm.date!)
        self.time = parsedDate
        
        // Get date string
        formatter.dateFormat = "MMM d, yyyy"
        parsedDate = formatter.string(from: alarm.date!)
        self.date = parsedDate  
    }
}
