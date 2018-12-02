//
//  Alarm.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 11/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import Foundation

class Alarm {
    var time: String
    var active: Bool
    
    init(time: String, active: Bool) {
        self.time = time
        self.active = active
    }
}
