//
//  AccordionHeaderView.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 2/11/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import Foundation
import FZAccordionTableView

class AccordionHeaderView: FZAccordionTableViewHeaderView {
    @IBOutlet weak var sectionHeaderTitleLabel: UILabel!
    
   
    static let defaultAccordionHeaderViewHeight: CGFloat = 44.0
    static let accordionHeaderViewReuseIdentifier = "AccordionHeaderViewReuseIdentifier"
}
