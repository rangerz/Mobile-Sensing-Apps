//
//  Alarms.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/2/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import Foundation

final class Alarms {
    static let sharedInstance = Alarms()
    var alarms: [Alarm] = []
    
    fileprivate init() {
        getAlarms()
    }
    
    fileprivate func getAlarms() {
        // TODO: Load alarms from internal memory
        for _ in 0...5 {
            var dateComponens = DateComponents(year: 2018, month: 12, day: 2, hour: 19, minute: 30)
            alarms.append(Alarm(time: "\(dateComponens.hour!):\(dateComponens.minute!)", active: true))
        }
    }
}
