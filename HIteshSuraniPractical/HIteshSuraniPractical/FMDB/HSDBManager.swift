//
//  HSDBManager.swift
//  HIteshSuraniPractical
//
//  Created by sooryen on 28/05/19.
//  Copyright © 2019 sooryen. All rights reserved.
//


import Foundation


class HSDBManager: NSObject {
    
    
    //sharedInstance
    static let sharedInstance = HSDBManager()
    
    func intiliseDatabase() -> URL? {
        
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentDirectory:URL = urls.first {
            do {
                try (documentDirectory as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            } catch _{
                print("Failed to exclude backup")
            }
            
            // This is where the database should be in the documents directory
            let finalDatabaseURL = documentDirectory.appendingPathComponent("HIteshSuraniPractical.db")
            
            if (finalDatabaseURL as NSURL).checkResourceIsReachableAndReturnError(nil) {
                return finalDatabaseURL
            } else {
                if let bundleURL = Bundle.main.url(forResource: "HIteshSuraniPractical", withExtension: "db") {
                    
                    do {
                        try fileManager.copyItem(at: bundleURL, to: finalDatabaseURL)
                    } catch _ {print("Couldn't copy file to final location!")}
                    
                } else {print("Couldn't find initial database in the bundle!")}
            }
        } else {
            print("Couldn't get documents directory!")
        }
        
        return nil
    }
    
    
    
    func methodToInsertUpdateDeleteData(_ strQuery : String,completion: @escaping (_ result: Bool) -> Void)
    {
        
        let contactDB = FMDatabase(path: String(intiliseDatabase()!.absoluteString) )
        
        if (contactDB?.open())! {
            
            let insertSQL = strQuery
            
            let result = contactDB?.executeUpdate(insertSQL,
                                                  withArgumentsIn: nil)
            
            if !result! {
                print("Failed to add contact")
                print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
                completion(false)
                
            } else {
                print("Contact Added")
                completion(true)
                
            }
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            completion(false)
            
        }
        
    }
    
    
    func methodToSelectData(_ strQuery : String,completion: @escaping (_ result: NSMutableArray) -> Void)
    {
        
        let arryToReturn : NSMutableArray = []
        
        let contactDB = FMDatabase(path: String(intiliseDatabase()!.absoluteString) )
        
        if (contactDB?.open())! {
            let querySQL = strQuery
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
            
            while results?.next() == true
            {
                arryToReturn.add(results!.resultDictionary())
            }
            
            // NSLog("%@", arryToReturn)
            
            if arryToReturn.count == 0
            {
                let dict = NSMutableDictionary()
                dict.setValue("No Record Found", forKey: "ErrorMessage")
                arryToReturn.addObjects(from: [dict])
                completion(arryToReturn)
            }
            
            contactDB?.close()
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
        }
        
        completion(arryToReturn)
        
    }
}
