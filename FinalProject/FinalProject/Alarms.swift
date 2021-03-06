//
//  Alarms.swift
//  FinalProject
//
//  Created by Alejandro Henkel on 12/2/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

final class Alarms {
    static let sharedInstance = Alarms()
    var alarms: [AlarmModel] = []
    var alarmsDb: [NSManagedObject] = []
    var soundManager = SoundManager.sharedInstance
    
    fileprivate init() {
        refreshData()
    }
    
    func refreshData() {
        var tempArr: [AlarmModel] = []
                
        let managedContext = getDBContext()
        
        // Query CoreData to fetch alarms
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Alarm")
        
        do {
            alarmsDb = try managedContext.fetch(fetchRequest)
            // Save each result as model
            alarmsDb.forEach{ alarm in
                tempArr.append(AlarmModel(alarm: alarm as! Alarm))
            }
            // Replace new data
            alarms = tempArr
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func save(date: Date) -> Bool {
        let alarmHash = randomString(length: 4)
        let alarmNameIndex = soundManager.getRandomAlarmIndex()
        let managedContext = getDBContext()
        // Create new object to be added and add its values
        let entity =
            NSEntityDescription.entity(forEntityName: "Alarm",
                                       in: managedContext)!
        let alarm = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        alarm.setValue(date, forKeyPath: "date")
        alarm.setValue(alarmHash, forKey: "id")
        alarm.setValue(alarmNameIndex, forKey: "alarmNameIndex")
        
        // Save context
        do {
            try managedContext.save()
            // Create notification with date and index of object
            createNotification(date: date, nextIndex: alarmsDb.count, hash: alarmHash, alarmNameIndex: alarmNameIndex)
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func createNotification(date: Date, nextIndex: Int, hash: String, alarmNameIndex: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Wake up!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!", arguments: nil)
//        content.sound = UNNotificationSound.default
        
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundManager.getAlarmNameForIndex(index: alarmNameIndex)))
        
        
        let userCalendar = Calendar.current
        let dateComponents = userCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // Debug trigger, to not wait until selected time
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let request = UNNotificationRequest(identifier: "Alarm-\(nextIndex)-\(alarmNameIndex)-\(hash)", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func deleteItem(index: Int, removeNotification: Bool) -> Bool {
        let managedContext = getDBContext()
        
        // If alarm hasn't sound, cancel alarm notification
        if removeNotification {
            // Get alarm object
            let toRemove = alarms[index]
            // Cancel notification by reconstructing its identifier
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Alarm-\(index)-\(toRemove.alarmNameIndex)-\(toRemove.hash)"])
        }

        do {
            // Delete alarm in current context
            managedContext.delete(alarmsDb[index])
            
            // Save context to persist changes
            try managedContext.save()
            return true
        } catch {
            fatalError("Failure to save context: \(error)")
        }

        
    }
    
    func getDBContext() -> NSManagedObjectContext {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Failure to get context")
        }
        
        return appDelegate.persistentContainer.viewContext
    }
    
    // Generate a random key to uniquely identify each alarm while deleting it
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
}
