//
//  FZAccordionTableView.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

class FZAccordionTableView: UITableView {

    var allowMultipleSectionsOpen: Bool
    var keepOneSectionOpen: Bool
    var initialOpenSection: Set<NSNumber>?
    var enableAnimationFix: Bool
    
    
    
    init?(allowsMultipleSectionsOpen: Bool, keepOneSectionOpen: Bool, initialOpenSection: Set<NSNumber>?, enableAnimationFix: Bool, frame: CGRect, style: UITableViewStyle) {
        //super.init()
        self.allowMultipleSectionsOpen = allowsMultipleSectionsOpen
        self.keepOneSectionOpen = keepOneSectionOpen
        if let initialSection = initialOpenSection {
            self.initialOpenSection = initialSection
        }
        self.enableAnimationFix = enableAnimationFix
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   

    
    func isSectionOpen(_ section: Int) -> Bool {
     return true
    }
    func toggleSection(_ section: Int) {
        
    }
    func section(forHeaderView headerView: UITableViewHeaderFooterView) -> Int {
        return 0
    }

}
