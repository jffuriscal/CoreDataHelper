//
//  File.swift
//  
//
//  Created by Jomar Furiscal on 12/18/20.
//

import Foundation
import CoreData

public class DBModel: NSObject {
    
    let context: NSManagedObjectContext
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer! = nil
    
    
    // MARK: - Core Data stack
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("CoreData error: \(nserror.userInfo)")
                #if DEBUG
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                #endif
            }
        }
    }
    
    // MARK: - User Controls
    /**
     * NSFetchRequestResult
     */
    
    public func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        
        do {
            let result = try context.fetch(request)
            return result
        }catch{
            return nil
        }
    }
    
    public func deleteRequest<T: NSManagedObject>(type: T.Type) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
