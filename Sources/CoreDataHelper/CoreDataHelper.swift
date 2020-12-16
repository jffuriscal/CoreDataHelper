//
//  File.swift
//  
//
//  Created by Jomar Furiscal on 12/16/20.
//

import Foundation
import CoreData

public var coredata_name: String = ""
public var coredata_extension: String = ""

public class ObjectManager {
    public static let shared = ObjectManager()
    let storeModel: DBModel
    
    private init() {
        storeModel = DBModel()
    }
    
    @available(iOS 10.0, *)
    public func setContainer(_ container: NSPersistentContainer) {
        storeModel.setContext(container: container)
    }
    
    private func fetchRequest<T: NSManagedObject>(type: T.Type) -> NSFetchRequest<T> {
        return NSFetchRequest<T>(entityName: String(describing: type))
    }
    
    private func executeFetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        return storeModel.executeFetchRequest(request)
    }
    
    private func fetch<T: NSManagedObject>(withPredicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int = 0, _ ofType: T.Type) -> (success: Bool, items: [T]) {
        
        let request: NSFetchRequest<T> = fetchRequest(type: ofType)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = fetchLimit
        
        guard let result = self.executeFetch(request as! NSFetchRequest<NSFetchRequestResult>) as? [T] else { return (false, []) }
        return (true, result)
    }
    
    public func add<T: NSManagedObject>(ofType: T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: ofType), into: storeModel.context) as! T
    }
    
    public func getOne<T: NSManagedObject>(ofType: T.Type, predicate: String, value: String) -> T? {
        
        let predicate = NSPredicate(format: "\(predicate) == %@", value)
        let result = fetch(withPredicate: predicate, ofType)
        
        return result.items.first
    }
    
    public func getAll<T: NSManagedObject>(withFilter filters: [String:String]? = nil, fetchLimit: Int = 0, sortedBy: String = "id", ofType: T.Type) -> [T] {
        var str = ""
        var predicate: NSPredicate? = nil
        if let filters = filters {
            for (key,value) in filters {
                let string = str.isEmpty ? "\(key) == \"\(value)\"" : " && \(key) == \"\(value)\""
                str.append(string)
            }
            predicate = NSPredicate(format: str)
        }
        let sort = NSSortDescriptor(key: sortedBy, ascending: true)
        let result = fetch(withPredicate: predicate, sortDescriptors: [sort], fetchLimit: fetchLimit, ofType)
        
        return result.items
    }
    
    public func deleteOne<T: NSManagedObject>(_ item: T) {
        storeModel.context.delete(item)
    }
    
    public func deleteAll<T: NSManagedObject>(_ ofType: T.Type) {
        _ = storeModel.deleteRequest(type: ofType)
    }
    
    public func save() {
        storeModel.saveContext()
    }
}

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

public class ObjectContext: NSManagedObjectContext {
        
    init() {
        
        super.init(concurrencyType: .privateQueueConcurrencyType)
        
        // This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: coredata_name, withExtension: coredata_extension) else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application.
        // It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error in initializing mom from: \(modelURL)")
        }
        
        // Persistence Store Coordinator
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Unable to resolve document directory")
        }
        
        let storeURL = docURL.appendingPathComponent("\(coredata_name).sqlite")
        
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        self.persistentStoreCoordinator = psc
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
