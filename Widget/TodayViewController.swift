//
//  TodayViewController.swift
//  Widget
//
//  Created by Manuel Leitold on 19.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    var timeTable: TimeTable? {
        didSet {
            timeTable?.saveInStore()
            self.tableView.reloadData()
            self.preferredContentSize.height = self.tableView.contentSize.height
        }
    }
    
    var error: NSError? {
        didSet {
            self.tableView.reloadData()
            self.preferredContentSize.height = self.tableView.contentSize.height
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if error != nil {
            return 1
        }
        
        return timeTable?.events.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventTableViewCell
        
        if error != nil {
            cell.titleLabel?.text = "\(error!.localizedDescription)"
        } else {
            if let event = timeTable?.events[indexPath.row] {
                cell.titleLabel.text = event.title
                cell.lecturerLabel.text = event.lecturer
                cell.locationLabel.text = event.location
                
                let dateFormatter = NSDateFormatter()
                let timeFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                timeFormatter.dateFormat = "HH:mm"
                
                cell.dateLabel.text = dateFormatter.stringFromDate(event.startDate)
                cell.timeLabel.text = "\(timeFormatter.stringFromDate(event.startDate))"
                "- \(timeFormatter.stringFromDate(event.endDate))"
            }  
        }
        
        return cell
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        FHPI(department: "itm", year: 2015).timeTable(5, filter: ["G1"])
        .startWithSignal { (signal, _) in
            signal.observeNext { timeTable in
                if self.timeTable == timeTable {
                    return completionHandler(.NoData)
                }
                
                self.timeTable = timeTable
                self.error = nil
                completionHandler(.NewData)
            }
            
            signal.observeFailed { error in
                self.timeTable = nil
                self.error = error
                completionHandler(.Failed)
            }
        }
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
