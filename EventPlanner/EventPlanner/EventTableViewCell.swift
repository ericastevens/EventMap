//
//  EventTableViewCell.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

import UIKit
import MapKit

class EventTableViewCell: UITableViewCell {
    
    lazy var view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var eventMapView: MKMapView = {
        let mapView: MKMapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.mapType = .standard
        mapView.layer.cornerRadius = 0.5 * mapView.bounds.size.width
        mapView.clipsToBounds = true
        return mapView
    }()
    
    lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var eventStartLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var eventEndLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15.5, weight: UIFontWeightRegular)
        label.textAlignment = .center
        return label
    }()
    
    lazy var eventTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        label.backgroundColor = .lightGray
        label.textColor = .white
        label.layer.cornerRadius = 0.5 * label.bounds.size.width
//        label.layer.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        label.clipsToBounds = true
     
        return label
    }()
    
    lazy var eventAddressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var toggleDirectionsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Directions", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        //button.showsTouchWhenHighlighted = true
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.layer.borderColor = UIColor.blue.cgColor
        button.addTarget(self, action: #selector(toggleDirectionsButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()
    
    //var showDirections = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //add subviews and constraints
        addSubviews()
        addSubviewConstraints()
        
        
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.heightAnchor.constraint(equalToConstant: 175)
        self.layoutSubviews()
        //        toggleDirectionsButton.addTarget(self, action: #selector(EventViewController.toggleDirectionsButtonPressed(sender:)), for: .touchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func addSubviews() {
        self.contentView.addSubview(view)
        view.addSubview(eventStartLabel)
        view.addSubview(eventNameLabel)
        view.addSubview(eventAddressLabel)
        view.addSubview(eventMapView)
        view.addSubview(eventEndLabel)
        view.addSubview(eventTypeLabel)
        view.addSubview(toggleDirectionsButton)
    }
    
    var showDirections = false
    
    func addSubviewConstraints() {
        //Cell Constraints
        _ = [
            //Add card view constraints
            view.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            view.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.9),
            view.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.9),
            
            //add event start time label constraints
            eventStartLabel.topAnchor.constraint(equalTo: view.topAnchor),
            eventStartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventStartLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            eventStartLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            //mapViewConstraints
            eventMapView.heightAnchor.constraint(equalToConstant: 80),
            eventMapView.widthAnchor.constraint(equalToConstant: 80),
            eventMapView.topAnchor.constraint(equalTo: eventStartLabel.bottomAnchor, constant: 16.0),
            eventMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            
            
            //event name label constraints
            eventNameLabel.topAnchor.constraint(equalTo: eventStartLabel.bottomAnchor, constant: 8.0),
            eventNameLabel.leadingAnchor.constraint(equalTo: eventMapView.trailingAnchor, constant: 8.0),
            eventNameLabel.trailingAnchor.constraint(equalTo: eventTypeLabel.leadingAnchor, constant: 0.0),
            eventNameLabel.bottomAnchor.constraint(equalTo: eventAddressLabel.topAnchor, constant: 0.0),
            eventNameLabel.widthAnchor.constraint(equalTo: eventStartLabel.widthAnchor, multiplier: 0.5),
            
            //event address label constraints
            eventAddressLabel.topAnchor.constraint(equalTo: eventNameLabel.bottomAnchor, constant: 8.0),
            eventAddressLabel.leadingAnchor.constraint(equalTo: eventMapView.trailingAnchor, constant: 8.0),
            eventAddressLabel.heightAnchor.constraint(equalTo: eventMapView.heightAnchor, multiplier: 0.5),
            eventAddressLabel.bottomAnchor.constraint(equalTo: toggleDirectionsButton.topAnchor, constant: 0.0),
            eventAddressLabel.trailingAnchor.constraint(equalTo: eventTypeLabel.leadingAnchor, constant: 0.0),
            eventAddressLabel.widthAnchor.constraint(equalTo: eventStartLabel.widthAnchor, multiplier: 0.5),
            
            // event end label constraints
            eventEndLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            eventEndLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0),
        
            
         
            
            //event type label constraints
            eventTypeLabel.centerXAnchor.constraint(equalTo: eventEndLabel.centerXAnchor),
            eventTypeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 8.0),
            eventTypeLabel.widthAnchor.constraint(equalToConstant: 70),
            eventTypeLabel.heightAnchor.constraint(equalToConstant: 70),
            
            //directions button constraints
            toggleDirectionsButton.leadingAnchor.constraint(equalTo: eventMapView.trailingAnchor, constant: 8.0),
            toggleDirectionsButton.topAnchor.constraint(equalTo: eventAddressLabel.bottomAnchor, constant: -8.0),
            toggleDirectionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0),
            toggleDirectionsButton.heightAnchor.constraint(equalToConstant: 25)
            
            ].map { $0.isActive = true }
    }
    
    func toggleDirectionsButtonPressed(sender: UIButton) {
        showDirections = true
        print("Button pressed \(showDirections)")
        //toggleDirectionsButton.setTitle("Hide Button", for: <#T##UIControlState#>)
        //EventViewController.tableView(<#T##EventViewController#>)
        
    }
    
}

