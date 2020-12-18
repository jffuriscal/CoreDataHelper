//
//  File.swift
//  
//
//  Created by Jomar Furiscal on 12/18/20.
//

import Foundation
import CoreData

/// Core Data stack initialization.
///
/// - Parameters:
///     - context: Managed object context.
public class DBModel: NSObject {
    
    let context: NSManagedObjectContext
    
    // MARK: - Core Data stack
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Core Data Saving support
    /// Save changes made in the Core Data stack.
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
    /// Execute request to the Core Data stack.
    ///
    /// - Parameters:
    ///     - request: Fetch request on the Core Data stack.
    /// - Returns: An array of requested data or nil if an error occured while executing the request.
    public func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        
        do {
            let result = try context.fetch(request)
            return result
        }catch{
            return nil
        }
    }
    
    /// Request for deletion of object to the Core Data stack.
    ///
    /// - Parameters:
    ///     - type: Type of NSManagedObect subclass.
    /// - Returns: A boolean indicating the success or failure of the request.
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
