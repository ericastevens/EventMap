//
//  AccordionHeaderView.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit
import FZAccordionTableView


class AccordionHeaderView: FZAccordionTableViewHeaderView/*, FZAccordionTableViewDelegate */{
    
    
    
    @IBOutlet weak var sectionHeaderLabel: UILabel!
   // var delegate: FZAccordionTableViewDelegate!

    static let defaultAccordionHeaderViewHeight: CGFloat = 44.0
    static let accordionHeaderViewReuseIdentifier = "AccordionHeaderViewReuseIdentifier"
  
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.commonInit()
       
    }
    
//    private func commonInit() {
//        Bundle(for: AccordionHeaderView.self).loadNibNamed("AccordionHeaderView", owner: self, options: nil)
//        //guard let content = view else { return }
//        //content.frame = self.bounds
//        //content.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
//        //self.addSubview(content)
//    }
    
//    func touchesHeaderView(sender: FZAccordionTableViewHeaderView) {
//        delegate = self
//    }
}
