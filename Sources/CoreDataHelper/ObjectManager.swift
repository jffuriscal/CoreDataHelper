//
//  ObjectManager.swift
//  
//
//  Created by Jomar Furiscal on 12/18/20.
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

