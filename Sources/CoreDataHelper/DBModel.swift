//
//  File.swift
//  
//
//  Created by Jomar Furiscal on 12/18/20.
//

import Foundation
import CoreData

public class DBModel: NSObject {
    
    var context: NSManagedObjectContext! = nil
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer! = nil
    
    
    // MARK: - Core Data stack
    override init() {
        super.init()
        if #available(iOS 10.0, *) {
        }else {
            setContext()
        }
    }
    
    private func setContext() {
        context = ObjectContext()
    }
    
    @available(iOS 10.0, *)
    public func setContext(container: NSPersistentContainer) {
        context = persistentContainer.newBackgroundContext()
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
