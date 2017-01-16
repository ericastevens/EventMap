//
//  Event+Additions.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import Foundation

extension Event {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
    public override func prepareForDeletion() {
        print("Deleting")
    }
    
    var eventStartDateDescription: String {
        let calendar = NSCalendar.current
        guard let start = startDate else { return ""}
        let monthComponent = calendar.component(.month, from: start as Date)
        let dayComponent = calendar.component(.day, from: start as Date)
        let yearComponent = calendar.component(.year, from: start as Date)
        let weekday = calendar.component(.weekday, from: start as Date)
        
        print("DATE AS COMPONENTS: \(monthComponent)/\(dayComponent)/\(yearComponent)")
        
        switch weekday {
        case 1:
            return "Sunday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        case 2:
            return "Monday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        case 3:
            return "Tuesday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        case 4:
            return "Wednesday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        case 5:
            return "Thursday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        case 6:
            return "Friday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        case 7:
            return "Saturday, \(monthComponent)/\(dayComponent)/\(yearComponent)"
        default:
            return "\(monthComponent)/\(dayComponent)/\(yearComponent)"
        }
    }
    
    var eventStartTimeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let string = formatter.string(from: startDate! as Date)
        
        return "\(string)"
    }
    
    var eventEndTimeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let string = formatter.string(from: endDate! as Date)
        return "\(string)"
    }
    
}
