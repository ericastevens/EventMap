//
//  FZAccordionTableView.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

class FZAccordionTableView: UITableView, FZAccordionTableViewHeaderViewDelegate {

    var allowMultipleSectionsOpen: Bool = false
    var keepOneSectionOpen: Bool = true
    var initialOpenSections: Set<AnyHashable>
    var mutableInitialOpenSections: Set<AnyHashable>
    var enableAnimationFix: Bool = true
    //let accordionTableView: FZAccordionTableView
    var subclassDataSource: UITableViewDataSource
    var subclassDelegate: UITableViewDelegate & FZAccordionTableViewDelegate
    var delegateProxy: FZAccordionTableViewDelegateProxy
    var sectionInfos: [FZAccordionTableViewSectionInfo?]
    var numberOfSectionsCalled: Bool
    
    init(initialOpenSections: Set<AnyHashable>, mutableInitialOpenSections: Set<AnyHashable>, subclassDelegate: UITableViewDelegate & FZAccordionTableViewDelegate, subclassDataSource: UITableViewDataSource, delegateProxy: FZAccordionTableViewDelegateProxy, sectionInfos: [FZAccordionTableViewSectionInfo?], numberOfSectionsCalled: Bool, frame: CGRect, style: UITableViewStyle ) {
        
        self.initialOpenSections = initialOpenSections
       
        super.init(frame: frame, style: style)
        
        decideInitialOpenSections(self.initialOpenSections)
        setDelegate(subclassDelegate)
        selectDataSource(subclassDataSource)
       
        
    }
//
    override init(frame: CGRect, style: UITableViewStyle) {
        
        super.init(frame: frame, style: style)
        
        decideInitialOpenSections(self.initialOpenSections)
        setDelegate(subclassDelegate)
        selectDataSource(subclassDataSource)
        //self.initializeVars()
    }
    
    required init?(coder aDecoder: NSCoder) {
       
        super.init(coder: aDecoder)
         //self.initializeVars()
    }
//    func initializeVars() {
//        self.allowMultipleSectionsOpen = false
//        self.sectionInfos = [Any]()
//        self.numberOfSectionsCalled = false
//        self.enableAnimationFix = false
//        self.keepOneSectionOpen = false
//        self.delegateProxy = FZAccordionTableViewDelegateProxy(accordionTableView: self)
//    }
//    
    
    // MARK: - Override Setters -
    
    func decideInitialOpenSections(_ initialOpenedSections: Set<AnyHashable>) {
        assert(self.sectionInfos.count == 0, "'initialOpenedSections' MUST be set before the tableView has started loading data.")
        self.initialOpenSections = initialOpenedSections
        self.mutableInitialOpenSections = initialOpenedSections
    }
    // MARK: - UITableView Overrides -
    
    func setDelegate(_ delegate: UITableViewDelegate & FZAccordionTableViewDelegate) {
        self.subclassDelegate = delegate
        super.delegate = self.delegateProxy
    }
    
    func selectDataSource(_ dataSource: UITableViewDataSource) {
        self.subclassDataSource = dataSource
        super.dataSource = self.delegateProxy
    }
    
    override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        for (section, _) in sections.enumerated(){
            let sectionInfo = FZAccordionTableViewSectionInfo(numberOfRows: 0)
            self.sectionInfos.insert(sectionInfo, at: section)
        }
//        sections.enumerateIndexesUsingBlock( {(_ section: Int, _ stop: Bool) -> Void in
//            var sectionInfo = FZAccordionTableViewSectionInfo(numberOfRows: 0)
//            self.sectionInfos.insert(sectionInfo, at: section)
//        })
        super.insertSections(sections, with: animation)
    }
    
    override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        // Remove section info in reverse order to prevent array from
        // removing the wrong section due to the stacking effect of arrays
        for (section, _) in sections.enumerated().reversed() {
            self.sectionInfos.remove(at: section)
        }
//        sections.enumerate(withOptions: .reverse, usingBlock: {(_ section: Int, _ stop: Bool) -> Void in
//            self.sectionInfos.remove(at: section)
//        })
        super.deleteSections(sections, with: animation)
    }
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        #if DEBUG
            for indexPath: IndexPath in indexPaths {
                assert(self.isSectionOpen(indexPath.section), "Can't insert rows in a closed section: \(Int(indexPath.section)).")
            }
        #endif
        super.insertRows(at: indexPaths, with: animation)
    }
    
    // MARK: - Public Helper Methods -
    
    func isSectionOpen(_ section: Int) -> Bool {
        return self.sectionInfos[section]!.isOpen
    }
    
    func toggleSection(_ section: Int) {
        let headerView: FZAccordionTableViewHeaderView? = (self.headerView(forSection: section) as? FZAccordionTableViewHeaderView)
        self.toggleSection(section, withHeaderView: headerView)
    }
    
    func section(forHeaderView headerView: UITableViewHeaderFooterView) -> Int {
        var section: Int = NSNotFound
        var minSection: Int = 0
        var maxSection: Int = self.numberOfSections - 1
        let headerViewFrame: CGRect = headerView.frame
        var compareHeaderViewFrame: CGRect
        while minSection <= maxSection {
            let middleSection: Int = (minSection + maxSection) / 2
            compareHeaderViewFrame = self.rectForHeader(inSection: middleSection)
            if headerViewFrame.equalTo(compareHeaderViewFrame) {
                section = middleSection
            }
            else if headerViewFrame.origin.y > compareHeaderViewFrame.origin.y {
                minSection = middleSection + 1
                section = middleSection
                // Occurs when headerView sticks to the top
            }
            else {
                maxSection = middleSection - 1
            }
        }
        return section
    }
    // MARK: - Private Utility Helpers -
    
    func markSection(_ section: Int, open isOpen: Bool) {
        self.sectionInfos[section]?.isOpen
    }
    
    func getIndexPaths(forSection section: Int) -> [Any] {
        let numOfRows: Int = self.sectionInfos[section]!.numberOfRows
        var indexPaths = [Any]()
        for row in 0..<numOfRows {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        return indexPaths
    }
    
    func canInteractWithHeader(atSection section: Int) -> Bool {
        var canInteractWithHeader: Bool = true
        if (self.delegate?.responds(to: Selector(("tableView:canInteractWithHeaderAtSection:"))))! {
            canInteractWithHeader = self.subclassDelegate.tableView(self, canInteractWithHeaderAtSection: section)
        }
        return canInteractWithHeader
    }
    // MARK: - <FZAccordionTableViewHeaderViewDelegate> -
    
    func tappedHeaderView(_ sectionHeaderView: FZAccordionTableViewHeaderView) {
        assert(sectionHeaderView != nil, "Invalid parameter not satisfying: sectionHeaderView")
        let section: Int = self.section(forHeaderView: sectionHeaderView)
        self.toggleSection(section, withHeaderView: sectionHeaderView)
    }
    
    func closeAllSectionsExcept(_ section: Int) {
        // Get all of the sections that we need to close
        var sectionsToClose = Set<AnyHashable>()
        for i in 0..<self.numberOfSections {
            let sectionInfo: FZAccordionTableViewSectionInfo? = self.sectionInfos[i]
            if section != i && (sectionInfo?.isOpen)! {
                sectionsToClose.insert(i)
                
            }
        }
        // Close the found sections
        for sectionToClose: AnyHashable in sectionsToClose {
            // Change animations based off which sections are closed
            var closeAnimation: UITableViewRowAnimation = .top
            if section < Int(sectionToClose as! Int) {
                closeAnimation = .bottom
            }
            if self.enableAnimationFix {
                if !self.allowsMultipleSelection && (Int(sectionToClose as! Int) == self.sectionInfos.count - 1 || Int(sectionToClose as! Int) == self.sectionInfos.count - 2) {
                    closeAnimation = .fade
                }
            }
            self.closeSection(Int(sectionToClose as! Int), withHeaderView: (self.headerView(forSection: Int(sectionToClose as! Int)) as? FZAccordionTableViewHeaderView), rowAnimation: closeAnimation)
        }
    }
    // MARK: - Open / Closing
    
    func toggleSection(_ section: Int, withHeaderView sectionHeaderView: FZAccordionTableViewHeaderView?) {
        if !self.canInteractWithHeader(atSection: section) {
            return
        }
        // Keep at least one section open
        if self.keepOneSectionOpen {
            var countOfOpenSections: Int = 0
            for i in 0..<self.numberOfSections {
                if (self.sectionInfos[i]?.isOpen)! {
                    countOfOpenSections += 1
                }
            }
            if countOfOpenSections == 1 && self.isSectionOpen(section) {
                return
            }
        }
        let openSection: Bool = self.isSectionOpen(section)
        self.beginUpdates()
        // Insert/remove rows to simulate opening/closing of a header
        if !openSection {
            self.openSection(section, withHeaderView: sectionHeaderView)
        }
        else {
            // The section is currently open
            self.closeSection(section, withHeaderView: sectionHeaderView)
        }
        // Auto-collapse the rest of the opened sections
        if !self.allowMultipleSectionsOpen && !openSection {
            self.closeAllSectionsExcept(section)
        }
        self.endUpdates()
    }
    
    func openSection(_ section: Int, withHeaderView sectionHeaderView: FZAccordionTableViewHeaderView?) {
        if !self.canInteractWithHeader(atSection: section) {
            return
        }
        if self.subclassDelegate.responds(to: Selector(("tableView:willOpenSection:withHeader:"))) {
            self.subclassDelegate.tableView(self, willOpenSection: section, withHeader: sectionHeaderView)
        }
        var insertAnimation: UITableViewRowAnimation = .top
        if !self.allowMultipleSectionsOpen {
            // If any section is open beneath the one we are trying to open,
            // animate from the bottom
            var i = section - 1
            while i >= 0 {
                if (self.sectionInfos[i]?.isOpen)! {
                    insertAnimation = .bottom
                }
                i -= 1
            }
        }
        if self.enableAnimationFix {
            if !self.allowsMultipleSelection && (section == self.numberOfSections - 1 || section == self.numberOfSections - 2) {
                insertAnimation = .fade
            }
        }
        let indexPathsToModify: [Any] = self.getIndexPaths(forSection: section)
        self.markSection(section, open: true)
        self.beginUpdates()
        CATransaction.setCompletionBlock({() -> Void in
            if self.subclassDelegate.responds(to: Selector(("tableView:didOpenSection:withHeader:"))) {
                self.subclassDelegate.tableView(self, didOpenSection: section, withHeader: sectionHeaderView)
            }
        })
        self.insertRows(at: indexPathsToModify as! [IndexPath], with: insertAnimation)
        self.endUpdates()
    }
    
    func closeSection(_ section: Int, withHeaderView sectionHeaderView: FZAccordionTableViewHeaderView?) {
        self.closeSection(section, withHeaderView: sectionHeaderView, rowAnimation: .top)
    }
    
    func closeSection(_ section: Int, withHeaderView sectionHeaderView: FZAccordionTableViewHeaderView?, rowAnimation: UITableViewRowAnimation) {
        if !self.canInteractWithHeader(atSection: section) {
            return
        }
        if self.subclassDelegate.responds(to: Selector(("tableView:willCloseSection:withHeader:"))) {
            self.subclassDelegate.tableView(self, willCloseSection: section, withHeader: sectionHeaderView)
        }
        let indexPathsToModify: [Any] = self.getIndexPaths(forSection: section)
        self.markSection(section, open: false)
        self.beginUpdates()
        CATransaction.setCompletionBlock({() -> Void in
            if self.subclassDelegate.responds(to: Selector(("tableView:didCloseSection:withHeader:"))) {
                self.subclassDelegate.tableView(self, didCloseSection: section, withHeader: sectionHeaderView)
            }
        })
        self.deleteRows(at: indexPathsToModify as! [IndexPath], with: .top)
        self.endUpdates()
    }
    
}
