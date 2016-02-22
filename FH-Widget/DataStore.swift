//
//  DataStore.swift
//  FH-Widget
//
//  Created by Manuel Leitold on 19.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation

class DataStore {
    private static var dataStore = DataStore()
    private var defaults = NSUserDefaults(suiteName: "group.at.mani1337.fh-widget")!
    
    class func sharedDataStore() -> DataStore {
        return dataStore
    }
    
    private init() {
        
    }
    
    func read(key: String) -> AnyObject? {
        return defaults.objectForKey(key)
    }
    
    func write(object: AnyObject?, key: String) {
        defaults.setObject(object, forKey: key)
        defaults.synchronize()
    }
}

extension TimeTable {
    class func loadFromStore() -> TimeTable? {
        if let data = DataStore.sharedDataStore().read("lastTimeTable") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? TimeTable
        }
        
        return nil
    }
    
    func saveInStore() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        DataStore.sharedDataStore().write(data, key: "lastTimeTable")
    }
}