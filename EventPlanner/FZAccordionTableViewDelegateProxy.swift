//
//  FZAccordionTableViewDelegateProxy.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/17/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

class FZAccordionTableViewDelegateProxy: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak private(set) var accordionTableView: FZAccordionTableView?
    
    init(accordionTableView: FZAccordionTableView) {
        super.init()
        
        self.accordionTableView = accordionTableView
        
    }
    
    // MARK: - Forwarding handling -
    
    override func forwardingTarget(for aSelector: Selector) -> Any {
        if (self.accordionTableView?.subclassDataSource.responds(to: aSelector))! {
            return self.accordionTableView!.subclassDataSource
        }
        else if (self.accordionTableView?.subclassDelegate.responds(to: aSelector))! {
            return self.accordionTableView!.subclassDelegate
        }
        
        return super.forwardingTarget(for: aSelector)!
    }
    
    override func responds(to aSelector: Selector) -> Bool {
        do { return super.responds(to: aSelector) || self.accordionTableView!.subclassDelegate.responds(to: aSelector) || self.accordionTableView!.subclassDataSource.responds(to: aSelector) }
        catch {
            fatalError()
        }
    }
    // MARK: - <UITableViewDataSource> -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.accordionTableView?.numberOfSectionsCalled = true
        var numOfSections: Int = 1
        // Default value for UITableView is 1
        if (self.accordionTableView?.subclassDataSource.responds(to: #selector(self.numberOfSections)))! {
            
            numOfSections = self.accordionTableView!.subclassDataSource.numberOfSections!(in: tableView)
        }
        // Create 'FZAccordionTableViewSectionInfo' objects to represent each section
        for i in (self.accordionTableView?.sectionInfos.count)!..<numOfSections {
            let section = FZAccordionTableViewSectionInfo(numberOfRows: 0)
            // Account for any initial open sections
            if (self.accordionTableView?.mutableInitialOpenSections.count)! > 0 && (self.accordionTableView?.mutableInitialOpenSections.contains((i)))! {
                section.isOpen = true
                self.accordionTableView?.mutableInitialOpenSections.remove(at: self.accordionTableView?.mutableInitialOpenSections.index(of: (i)) ?? (self.accordionTableView?.mutableInitialOpenSections.index(of: AnyHashable(-1)))! )
            }
            self.accordionTableView?.sectionInfos.append(section)
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(self.accordionTableView?.numberOfSectionsCalled)! {
            // There is some potential UITableView bug where
            // 'tableView:numberOfRowsInSection:' gets called before
            // 'numberOfSectionsInTableView' gets called.
            return 0
        }
        var numOfRows: Int = 0
        if (self.accordionTableView?.subclassDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))))! {
            numOfRows = (self.accordionTableView?.subclassDataSource.tableView(tableView, numberOfRowsInSection: section))!
        }
        self.accordionTableView?.sectionInfos[section]?.numberOfRows = numOfRows
        if !(self.accordionTableView?.isSectionOpen(section))! {
            numOfRows = 0
        }
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We implement this purely to satisfy the Xcode UITableViewDataSource warning
        return self.accordionTableView!.subclassDataSource.tableView(tableView, cellForRowAt: indexPath)
    }
//    // MARK: - <UITableViewDelegate> -
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView: FZAccordionTableViewHeaderView? = nil
        if (self.accordionTableView?.subclassDelegate.responds(to: #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))))! {
            headerView = (self.accordionTableView?.subclassDelegate.tableView!(tableView, viewForHeaderInSection: section) as? FZAccordionTableViewHeaderView)
            if headerView != nil {
                headerView?.delegate = self.accordionTableView
            }
        }
        return headerView!
    }
   
   }

