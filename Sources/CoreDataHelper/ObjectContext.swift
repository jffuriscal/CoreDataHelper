//
//  ObjectContext.swift
//  
//
//  Created by Jomar Furiscal on 12/18/20.
//

import Foundation
import CoreData

public class ObjectContext: NSManagedObjectContext {
        
    init(_ coredata_name: String, _ coredata_extension: String) {
        
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
