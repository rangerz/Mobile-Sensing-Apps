//
//  SoundManager.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import Foundation
import AVFoundation

final class SoundManager {
    static let sharedInstance = SoundManager()
    var audioPlayer: AVAudioPlayer?
    let alarmNames = ["analog.mp3", "clockbuzzer.mp3", "submarine.mp3"]
    
    func startAlarm(index: Int) {
        let path = Bundle.main.path(forResource: getAlarmNameForIndex(index: index), ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Couldn't load file")
        }
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
    }
    
    func getRandomAlarmName() -> String {
        return alarmNames[getRandomAlarmIndex()]
    }
    
    func getAlarmNameForIndex(index: Int) -> String {
        return alarmNames[index]
    }
    
    func getRandomAlarmIndex() -> Int {
        return Int.random(in: 0 ..< alarmNames.count)
    }
}
