//
//  ObjectManager.swift
//  
//
//  Created by Jomar Furiscal on 12/18/20.
//

import Foundation
import CoreData

public class ObjectManager {
    public static let shared = ObjectManager()
    var storeModel: DBModel! = nil
    
    private init() {}
    
    /**
     Initialize Core Data Model.
     Must be used on iOS 10 and above.
     
     - Parameter container: Persistent container of the Core Data stack
     */
    @available(iOS 10.0, *)
    public func setCoreDataModelV2(_ container: NSPersistentContainer) {
        let context = container.newBackgroundContext()
        storeModel = DBModel(context)
    }
    
    /**
     Initialize Core Data Model.
     Must be used on iOS 9 and below.
     
     - Parameters:
        - name: File name of the coredata model.
        - extension: File extension of the coredata model, default *momd*.
     */
    public func setCoreDataModel(name: String, extension: String = "momd") {
        let context = ObjectContext(name, `extension`)
        storeModel = DBModel(context)
    }
    
    /**
     Return a fetch request of the given NSManagedObject subclass.
     
     - Parameter type: Type of the NSManagedObject subclass.
     - Returns: NSFetchRequest of NSManagedObject subclass
     */
    private func fetchRequest<T: NSManagedObject>(type: T.Type) -> NSFetchRequest<T> {
        return NSFetchRequest<T>(entityName: String(describing: type))
    }
    
    /**
     Return a fetch request of the given NSManagedObject subclass.
     
     - Parameter request: request of type NSFetchRequest.
     - Returns: An array of NSManagedObject subclass
     */
    private func executeFetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        return storeModel.executeFetchRequest(request)
    }
    
    /**
     Return a fetch request of the given NSManagedObject subclass.
     
     - Parameters:
        - withPredicate: Filtering of items to be fetched.
        - sortDescriptors: Ordering for the fetched items.
        - fetchLimit: Limit of items to be fetched.
        - ofType: Type of NSManagedObject subclass.
     - Returns: An array of NSManagedObject subclass
     */
    private func fetch<T: NSManagedObject>(withPredicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int = 0, _ ofType: T.Type) -> [T] {
        
        let request: NSFetchRequest<T> = fetchRequest(type: ofType)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = fetchLimit
        
        guard let result = self.executeFetch(request as! NSFetchRequest<NSFetchRequestResult>) as? [T] else { return [] }
        return result
    }
    
    /**
     Create new  NSManagedObject item.
     
     - Parameters:
        - ofType: Type of NSManagedObject subclass.
     - Returns: An NSManagedObject subclass
     */
    public func add<T: NSManagedObject>(ofType: T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: ofType), into: storeModel.context) as! T
    }
    
    /**
     Return an NSManagedObject if it exists otherwise nil.
     
     - Parameters:
        - predicate: Field to be filtered.
        - value: Value of the field to be filtered.
        - ofType: Type of NSManagedObject subclass.
     - Returns: An array of NSManagedObject subclass
     */
    public func getOne<T: NSManagedObject>(ofType: T.Type, predicate: String, value: String) -> T? {
        
        let predicate = NSPredicate(format: "\(predicate) == %@", value)
        let result = fetch(withPredicate: predicate, ofType)
        
        return result.first
    }
    
    /**
     Return all items of the given NSManagedObject subclass.
     
     - Parameters:
        - withFilter: Fields to be used for filtering.
        - sortedBy: Field to be used for sorting items.
        - fetchLimit: Limit of items to be fetched.
        - ofType: Type of NSManagedObject subclass.
     - Returns: An array of NSManagedObject subclass
     */
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
        
        return result
    }
    
    /**
     Deletes one item of NSManagedObject subclass.
     
     - Parameters:
        - item: NSManagedObject to be deleted.
     */
    public func deleteOne<T: NSManagedObject>(_ item: T) {
        storeModel.context.delete(item)
    }
    
    /**
     Deletes all items of NSManagedObject subclass.
     
     - Parameters:
        - ofType: Type of NSManagedObject subclass.
     */    public func deleteAll<T: NSManagedObject>(_ ofType: T.Type) {
        _ = storeModel.deleteRequest(type: ofType)
    }
    
    /**
     Save changes to the core data.
     */
    public func save() {
        storeModel.saveContext()
    }
}

