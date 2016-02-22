//
//  FHPI.swift
//  iOS-FH-Widget
//
//  Created by Manuel Leitold on 19.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation
import EVReflection
import XMLDictionary
import ReactiveCocoa

class EventInfo : EVObject {
    var title = ""
    var lecturer = ""
    var location = ""
    var type = ""
    var start = 0
    var end = 0
    
    var startDate: NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(start))
    }
    
    var endDate: NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(end))
    }
}

@objc(TimeTable) class TimeTable : EVObject {
    var __name = ""
    var status = ""
    var course = ""
    var year = 0
    var Event: [EventInfo]? = []
    
    var events : [EventInfo] {
        return Event ?? []
    }
}

class FHPI {
    var department: String
    var year: Int
    
    init(department: String, year: Int) {
        self.department = department
        self.year = year
    }
    
    func timeTable(maxElements: Int?, filter: [String]?) -> SignalProducer<TimeTable, NSError> {
        let url = NSURL(string: "https://ws.fh-joanneum.at/getschedule.php?c=\(department)&y=\(year)&k=LOvkZCPesk")!
        let urlRequest = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        return session.rac_dataWithRequest(urlRequest)
        .map { (data, response) -> TimeTable in
            return TimeTable(dictionary: NSDictionary(XMLData: data))
        }
        .map({ (timeTable) -> TimeTable in
            if maxElements == nil && filter == nil {
                return timeTable
            }
            
            // Apply filter
            if var events = timeTable.Event where events.count > 0 && filter !=  nil {
                for var i = 0; i < events.count; i++ {
                    for f in filter! {
                        if events[i].type == f {
                            events.removeAtIndex(i--)
                            break
                        }
                    }
                }
                timeTable.Event = events
            }
            
            // Apply max count
            if maxElements != nil {
                if var events = timeTable.Event where events.count > maxElements! {
                    events.removeRange(maxElements! ..< events.count)
                    timeTable.Event = events
                }
            }
            
            return timeTable
        })
        .observeOn(UIScheduler())
    }
}