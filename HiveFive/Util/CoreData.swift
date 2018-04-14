//
//  CoreData.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreData {
    static var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
    }()
    
    /**
     - Parameter entity: The name of the entity to be deleted.
     */
    static func delete(entity: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try? CoreData.context.execute(request)
    }
    
    /**
     Deletes an object from Core Data if it meets a certain set of conditions.
     - Parameter entity: The name of the entity to be deleted.
     - Parameter predicate: A boolean that indicates wheter an object should be deleted
     */
    static func delete(entity: String, predicate shouldDelete: (Any) -> Bool) {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let fetchedObjects = try context.fetch(fetchRequest) as [Any]
            if(fetchedObjects.count > 0) {
                fetchedObjects.filter{shouldDelete($0)}.forEach {obj in
                    context.delete(obj as! NSManagedObject)
                }
                do {
                    try context.save()
                } catch {
                    print("Error in Deletion : \(error)")
                }
            }
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
