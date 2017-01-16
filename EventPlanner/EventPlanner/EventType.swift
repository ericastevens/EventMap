//
//  EventType.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import Foundation

import Foundation
import UIKit

enum EventType: String {
    case Meeting = "Business Meeting"
    case HolidayParty = "Holiday Party"
    case HappyHour = "Happy Hour"
    case Gala = "Gala"
    case Fundraiser = "Fundraiser"
    case Conference = "Conference"
    case Networking = "Networking"
    case DateNight = "Date Night"
    case Workshop = "Workshop"
    
    static let eventArr = [Meeting.rawValue, HolidayParty.rawValue, HappyHour.rawValue, Gala.rawValue, Fundraiser.rawValue, Conference.rawValue, Networking.rawValue, DateNight.rawValue, Workshop.rawValue]
    
    static let correspondingRGBDict: [EventType:UIColor] = [
        EventType.HolidayParty : UIColor(red:0.48, green:0.09, blue:0.26, alpha:1.0)/*wine red*/,
        EventType.Meeting : UIColor(red:0.11, green:0.38, blue:0.61, alpha:1.0)/*cobalt*/,
        EventType.HappyHour : UIColor(red:0.95, green:0.58, blue:0.23, alpha:1.0),
        EventType.Gala:  UIColor(red:0.69, green:0.09, blue:0.56, alpha:1.0) /*bright purple*/,
        EventType.Fundraiser : UIColor(red:0.12, green:0.35, blue:0.27, alpha:1.0)/*forest green*/,
        EventType.Conference : UIColor(red:0.07, green:0.66, blue:0.88, alpha:1.0) /*cerulean*/,
        EventType.Networking : UIColor(red:0.82, green:0.44, blue:0.09, alpha:1.0) /*orange*/,
        EventType.DateNight : UIColor(red:0.78, green:0.42, blue:0.60, alpha:1.0)/*bright pink*/,
        EventType.Workshop : UIColor(red:0.40, green:0.60, blue:0.64, alpha:1.0)/*deep turquoise*/,
    ]
}
