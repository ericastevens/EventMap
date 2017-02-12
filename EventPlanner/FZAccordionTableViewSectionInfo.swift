//
//  FZAccordionTableViewSectionInfo.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/17/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

class FZAccordionTableViewSectionInfo: NSObject {
    var isOpen: Bool = false
    var numberOfRows: Int = 0
    
    
    init(numberOfRows: Int) {
        super.init()
        
        self.numberOfRows = numberOfRows
        
    }
}
