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

final class Alarms {
    static let sharedInstance = Alarms()
    var alarms: [AlarmModel] = []
    var alarmsDb: [NSManagedObject] = []
    
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
        let managedContext = getDBContext()
        // Create new object to be added and add its values
        let entity =
            NSEntityDescription.entity(forEntityName: "Alarm",
                                       in: managedContext)!
        let alarm = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        alarm.setValue(date, forKeyPath: "date")
        
        // Save context
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func deleteItem(index: Int) -> Bool {
        let managedContext = getDBContext()
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
}
