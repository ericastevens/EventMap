//
//  AccordionHeaderView.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit
import FZAccordionTableView

protocol FZAccordionTableViewHeaderViewDelegate: NSObjectProtocol {
    func tappedHeaderView(_ sectionHeaderView: FZAccordionTableViewHeaderView)
}

class FZAccordionTableViewHeaderView: UITableViewHeaderFooterView, FZAccordionTableViewHeaderViewDelegate {
    
    
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    weak var delegate: FZAccordionTableViewHeaderViewDelegate?
    

    static let defaultAccordionHeaderViewHeight: CGFloat = 44.0
    static let accordionHeaderViewReuseIdentifier = "AccordionHeaderViewReuseIdentifier"
 
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.commonInit()
       
    }
    
    func singleInit() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.touchedHeaderView)))
    }
    
    internal func tappedHeaderView(_ sectionHeaderView: FZAccordionTableViewHeaderView) {
        print("HEADER WAS TAPPED!")
    }
    
    func touchedHeaderView(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.tappedHeaderView(self)
    }
    
}
