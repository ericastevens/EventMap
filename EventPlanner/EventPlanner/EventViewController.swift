//
//  EventViewController.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

import UIKit
import CoreData
import CoreLocation
import MapKit
import FZAccordionTableView


class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: Properties
    var event: Event? {
        didSet {
            print("EVENT? is set!\n\n\(event)")
        }
    }
    
    
    var toggleDirectionsButtonIsSelected: Bool!
    
    // Maps & Locations
    lazy var mapView: MKMapView = {
        let mapView: MKMapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        return mapView
    }()
    
    let locationManager: CLLocationManager = {
        let locMan: CLLocationManager = CLLocationManager()
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.distanceFilter = 50.0
        locMan.requestWhenInUseAuthorization()
        return locMan
    }()
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    let geocoder: CLGeocoder = CLGeocoder()
    //var mapLocations = [(Int,CLLocationCoordinate2D)]()
    var locationArr = [CLLocationCoordinate2D]()
    let userLocationAnnotation: MKPointAnnotation = MKPointAnnotation()
    let request = MKDirectionsRequest()
    var routes = [MKRoute]()
    var directionsResponseArr = [MKDirectionsResponse]()
    var polylineRenderer = MKPolylineRenderer()
    var directionsReceived = false
    
    
    // Views And Managers
    let eventCell = EventTableViewCell()
    
    // Tableview
    lazy var tableView: FZAccordionTableView = {
        let tb = FZAccordionTableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
        
    }()
    let cellIdentifier = "eventCellIdentifier"
    
    // Core Data
    var controller: NSFetchedResultsController<Event>!
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    var directionsShouldBeShown = false
    var directionsArr = [String]()
    
    
    // MARK: - View life cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //toggleDirectionsButtonIsSelected = false
        tableView.register(UINib(nibName: "AccordionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.accordionHeaderViewReuseIdentifier)
        
        // Setup tableview options
        self.tableView.delegate = self
        self.tableView.dataSource = self
        mapView.delegate = self
        locationManager.delegate = self
        tableView.separatorStyle = .none
        tableView.allowMultipleSectionsOpen = false
        tableView.keepOneSectionOpen = false
        //tableView.initialOpenSections = [0]
        //        tableView.enableAnimationFix = true
        
        
        
        
        
        
        
        // Setup views and layout
        setupViewHierarchy()
        setupConstraints()
        
        // Request permission to track location
        getAccessOfLocation()
        
        // Identify user's location
        locationManager.requestLocation()
        
        // TableView Register Cell
        self.tableView.register(EventTableViewCell.self, forCellReuseIdentifier: "EventCell")
        //originally 175
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.isSectionOpen(0)
        
        tableView.estimatedRowHeight = 175
        
        
        
        
        // Nav Bar Button Item (add event)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonPressed))
        
        // Core Data
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Event.startDate), ascending: true)]
        controller = NSFetchedResultsController(fetchRequest: request,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: "eventStartDateDescription",
                                                cacheName: nil)
        controller.delegate = self
        try! controller.performFetch()
        
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 175//Choose your custom row height
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    // MARK: - Layout
    func setupViewHierarchy() {
        self.view.addSubview(mapView)
        self.view.addSubview(tableView)
    }
    
    func setupConstraints() {
        let _ = [
            // mapView
            mapView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.333),
            
            // tableView
            tableView.topAnchor.constraint(equalTo: self.mapView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ].map{ $0.isActive = true }
    }
    
    
    
    //MARK: Methods
    func addButtonPressed() {
        let addEventViewController = AddEventViewController()
        
        if let navVC = self.navigationController {
            print("NavVC found")
            navVC.pushViewController(addEventViewController, animated: true)
        }
    }
    
    //    func showRoute(_ response: MKDirectionsResponse) {
    //        for route in response.routes {
    //            mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
    //            routes.append(route)
    //            for step in route.steps {
    //                print("DIRECTIONS \(step.instructions)")
    //            }
    //        }
    //    }
    
    func getAccessOfLocation() {
        // 1. Check authorization status:
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse: print("All Good")
        case .denied, .restricted:
            guard let validSettingsURL: URL = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(validSettingsURL, options: [:], completionHandler: nil)
        default:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    
    // MARK: - TableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = controller.sections {
            return sections.count
        }
        return 1
    }
    
    var didAddTodaysEvents = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let info = sections[section]
            return info.numberOfObjects
        }
        return 1
    }
    
    
    
    func addRoutes(_ responses: [MKDirectionsResponse]) {
        //print("LOCATIONSCOUNT: \(locations.count)")
        //for location in locations {
        responses.forEach { (response) in
            for route in response.routes {
                mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                routes.append(route)
                print("ROUTEARR: \(routes)")
                for step in route.steps {
                    print("DIRECTIONS \(step.instructions)")
                    directionsArr.append(step.instructions)
                }
            }
        }
        
        //}
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        
        let event = self.controller.object(at: indexPath)
        
        print("INDEXPATH ROW: \(indexPath.row), \(indexPath.section)")
        cell.selectionStyle = .none
        
        cell.eventMapView.removeAnnotations(cell.eventMapView.annotations) /*eliminates recurring annotaions */
        cell.eventMapView.layer.cornerRadius = 0.5 * cell.eventMapView.bounds.size.width
        cell.eventTypeLabel.layer.cornerRadius = 0.5 * cell.eventTypeLabel.bounds.size.width
        cell.clipsToBounds = true
        
        let eventLocationCoordinates = CLLocationCoordinate2DMake(event.latitude, event.longitude)
        let placemark = MKPlacemark(coordinate: eventLocationCoordinates)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = event.event
        annotation.subtitle = event.type
        
        cell.eventMapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.0025, 0.0025)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        cell.eventMapView.setRegion(region, animated: true)
        
        let calendar = NSCalendar.current
        if let startDate = event.startDate as? Date,
            let endDate = event.endDate as? Date {
            //format start date
            let startHourComponent = calendar.component(.hour, from: startDate)
            let startMinuteComponent = calendar.component(.minute, from: startDate)
            let startAmOrPm = event.eventStartTimeDescription.substring(from: event.eventStartTimeDescription.index(event.eventStartTimeDescription.endIndex, offsetBy: -2))
            var adjustedStartHourComponent = 0
            var startMinuteComponentString = ""
            
            //adjust military start time
            if startHourComponent > 12 {
                adjustedStartHourComponent = startHourComponent - 12
            } else {
                adjustedStartHourComponent = startHourComponent
            }
            
            //adds another zero to minute component
            if startMinuteComponent == 0 {
                startMinuteComponentString = String(describing: startMinuteComponent)
                let zeroString = "0"
                startMinuteComponentString.append(zeroString)
                print("MIUNTE COMPONENT STRING: \(startMinuteComponentString)")
            } else {
                startMinuteComponentString = String(describing: startMinuteComponent)
            }
            
            //format end date
            let endHourComponent = calendar.component(.hour, from: endDate)
            let endMinuteComponent = calendar.component(.minute, from: endDate)
            let endAmOrPm = event.eventEndTimeDescription.substring(from: event.eventEndTimeDescription.index(event.eventEndTimeDescription.endIndex, offsetBy: -2))
            var adjustedEndHourComponent = 0
            var endMinuteComponentString = ""
            
            //adjust military end time
            if endHourComponent > 12 {
                adjustedEndHourComponent = endHourComponent - 12
            } else {
                adjustedEndHourComponent = endHourComponent
            }
            
            if endMinuteComponent == 0 {
                endMinuteComponentString = String(describing: endMinuteComponent)
                let zeroString = "0"
                endMinuteComponentString.append(zeroString)
            } else {
                endMinuteComponentString = String(describing: endMinuteComponent)
            }
            
            //Set text for labels
            if let eventType = event.type,
                let eventName = event.event,
                let eventAddress = event.address {
                cell.eventStartLabel.text = "Starts at \(adjustedStartHourComponent):\(startMinuteComponentString) \(startAmOrPm)"
                cell.eventNameLabel.text = eventName
                cell.eventAddressLabel.text = eventAddress
                cell.eventEndLabel.text = "Ends at \(adjustedEndHourComponent):\(endMinuteComponentString) \(endAmOrPm)"
                
                let eventTypeWordCountArr = eventType.components(separatedBy: " ")
                if eventTypeWordCountArr.count == 1 {
                    cell.eventTypeLabel.numberOfLines = 1
                    cell.eventTypeLabel.adjustsFontSizeToFitWidth = true
                } else {
                    cell.eventTypeLabel.numberOfLines = 0
                }
                cell.eventTypeLabel.text = eventType
                print("ADDRESS: \(eventAddress)")
                
                //                if toggleDirectionsButtonIsSelected {
                //                    cell.toggleDirectionsButton.setTitle("Hide Directions", for: .normal)
                //                }
                
                //set color tag corresponding to event type
                switch eventType {
                case eventType where eventType == EventType.HolidayParty.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.HolidayParty]
                case eventType where eventType == EventType.Meeting.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.Meeting]
                case eventType where eventType == EventType.Conference.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.Conference]
                case eventType where eventType == EventType.Workshop.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.Workshop]
                case eventType where eventType == EventType.Networking.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.Networking]
                case eventType where eventType == EventType.Gala.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.Gala]
                case eventType where eventType == EventType.Fundraiser.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.Fundraiser]
                case eventType where eventType == EventType.HappyHour.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.HappyHour]
                case eventType where eventType == EventType.DateNight.rawValue:
                    cell.eventTypeLabel.backgroundColor = EventType.correspondingRGBDict[EventType.DateNight]
                default:
                    cell.eventTypeLabel.backgroundColor = .lightGray
                }
                print("TYPE WORD COUNT: \(eventTypeWordCountArr.count)")
            }
            print("EVENT: \(event.event)")
            print("\(startDate)")
            print("START: \(event.eventStartTimeDescription), END: \(event.eventEndTimeDescription)")
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccordionHeaderView.defaultAccordionHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection:section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionInfo = controller.sections?[section] else { fatalError() }
        guard let accordionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AccordionHeaderView.accordionHeaderViewReuseIdentifier) else { fatalError() }
        
        let rowsInSection = sectionInfo.numberOfObjects
        let accordionSectionHeader = accordionHeaderView as? AccordionHeaderView
        switch rowsInSection {
        case rowsInSection where rowsInSection > 1:
            accordionSectionHeader?.sectionHeaderTitleLabel.text = "\(rowsInSection) Events on \(sectionInfo.name)"
        case rowsInSection where rowsInSection == 1:
            accordionSectionHeader?.sectionHeaderTitleLabel.text = "\(rowsInSection) Event on \(sectionInfo.name)"
        default:
            accordionSectionHeader?.sectionHeaderTitleLabel.text = ""
            
        }
        
        return accordionHeaderView
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let object = controller.object(at: indexPath)
            context.delete(object)
            try! context.save()
            routes.forEach({ (route) in
                mapView.remove(route.polyline)
            })
            self.directionsReceived = false
            
            mapView.updateFocusIfNeeded()
        default:
            break
        }
    }
    
    //    //Add edit, delete event actions
    //    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    ////        ////https://www.ioscreator.com/tutorials/swipe-table-view-cell-custom-actions-tutorial-ios8-swift
    //
    //        //var editAction = UITableViewRowAction(style: .default, title: "Edit", handler: nil)
    //    let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Share" , handler: { (action, indexPath) -> Void in
    //        // 2
    //        let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .actionSheet)
    //
    //        let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.default, handler: nil)
    //        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    //
    //        shareMenu.addAction(twitterAction)
    //        shareMenu.addAction(cancelAction)
    //
    //
    //        //self.present(shareMenu, animated: true, completion: nil)
    //    })
    //    // 3
    //    let rateAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Rate" , handler: { (action, indexPath) -> Void in
    //        // 4
    //        let rateMenu = UIAlertController(title: nil, message: "Rate this App", preferredStyle: .actionSheet)
    //
    //        let appRateAction = UIAlertAction(title: "Rate", style: UIAlertActionStyle.default, handler: nil)
    //        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    //
    //        rateMenu.addAction(appRateAction)
    //        rateMenu.addAction(cancelAction)
    //
    //
    //        //self.present(rateMenu, animated: true, completion: nil)
    //    })
    //    // 5
    //    return [shareAction,rateAction]
    //
    //    }
    
    //MARK: NSFetchedResultsController Delegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        tableView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        //mapView.reloadInputViews()
    }
    
    // MARK: - CoreLocation Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized, start tracking")
            manager.startUpdatingLocation()
            
        case .denied, .restricted:
            print("Denied or restricted, change in settings!")
            
        default:
            self.locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Receiving location info!:")
        dump(locations)
        //USER LOCATION
        guard let validCurrentUserLocation = locations.first else { return }
        
        //    mapView.setCenter(validLocation.coordinate, animated: true)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(validCurrentUserLocation.coordinate, 8000, 8000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        
        userLocationAnnotation.coordinate = validCurrentUserLocation.coordinate
        
        userLocationAnnotation.title = "This is you"
        userLocationAnnotation.subtitle = "I see you. - Apple"
        
        
        print("CURRENTLOCATION AFTERUPDATEw: \(userLocationAnnotation.coordinate)")
        //mapLocations[0] = validCurrentUserLocation.coordinate
        
        //        let circleOverlay: MKCircle = MKCircle(center: annotation.coordinate, radius: 100.0)
        //        mapView.add(circleOverlay)
        
        geocoder.reverseGeocodeLocation(validCurrentUserLocation) { (placemark: [CLPlacemark]?, error: Error?) in
            if error != nil {
                dump(error!)
                return
            }
            
            //            dump(placemark)
            //            guard let validPlacemark: CLPlacemark = placemark?.last else { return }
            
        }
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Mapview Delegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .red
            polylineRenderer.lineWidth = 3
            
            return polylineRenderer
        } else {
            
            let circleOverlayRenderer: MKCircleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleOverlayRenderer.fillColor = UIColor.green.withAlphaComponent(0.25)
            circleOverlayRenderer.strokeColor = UIColor.green
            circleOverlayRenderer.lineWidth = 1.0
            
            return circleOverlayRenderer
        }
    }
}

// MARK: - <FZAccordionTableViewDelegate> -

extension EventViewController : FZAccordionTableViewDelegate {
    
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        print("WILL OPEN SECTION: \(section)\n")
        
        //remove annotations if all sections are closed
        //mapView.removeOverlays(mapView.overlays)
        //mapView.removeAnnotations(mapView.annotations)
        
        
        if let sections = controller.sections {
            let info = sections[section]
    
            //Add pins to main map based on section (date in focus)
            dump("OBJECTS: \(info.objects as? [Event])")
            
            if let eventsArr = info.objects as? [Event] {
                
                for i in 0..<eventsArr.count {
                    
                    //Add map annotation for each event listed for currently selected day
                    let eventLocationCoordinates = CLLocationCoordinate2DMake(eventsArr[i].latitude, eventsArr[i].longitude)
                    let placemark = MKPlacemark(coordinate: eventLocationCoordinates)
                    let eventAnnotation = MKPointAnnotation()
                    
                    eventAnnotation.coordinate = placemark.coordinate
                    eventAnnotation.title = eventsArr[i].event
                    eventAnnotation.subtitle = eventsArr[i].type
                    
                    mapView.addAnnotation(eventAnnotation)
                    
                    //Calculate routes
                    switch i {
                    case i where i == 0:
                        request.source = MKMapItem.forCurrentLocation() //starting point, users location
                        request.destination = MKMapItem(placemark: placemark) //should be first element in array (first event)
                        request.requestsAlternateRoutes = false
                        
                        let directions = MKDirections(request: request)
                        
                        directions.calculate(completionHandler: {(response, error) in
                            guard let response = response else {
                                print("Error getting directions")
                                return
                            }
                            self.directionsResponseArr.append(response)
                        })
                        
                    default:
                        let previousEventLocationCoordinates = CLLocationCoordinate2DMake(eventsArr[i-1].latitude, eventsArr[i-1].longitude)
                        let previousEventPlacemark = MKPlacemark(coordinate: previousEventLocationCoordinates)
                        
                        request.source = MKMapItem(placemark: previousEventPlacemark) //should be first element in array (first event)
                        request.destination = MKMapItem(placemark: placemark)
                        request.requestsAlternateRoutes = false
                        
                        let directions = MKDirections(request: request)
                        
                        directions.calculate(completionHandler: {(response, error) in
                            guard let response = response else {
                                print("Error getting directions")
                                return
                            }
                            print("RESPONSE: \(response.source)")
                            
                            self.directionsResponseArr.append(response)
                        })
                    }
                    print("EVENTSARRCOUNT: \(eventsArr.count)")
                    //Adjust map span to include all annotations
                }
            }
            self.addRoutes(directionsResponseArr)
            print("DIRECTIONSRESPONSEARR COUNT: \(directionsResponseArr.count)")
            directionsResponseArr = [MKDirectionsResponse]()
        }
        
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        print("DID OPEN SECTION: \(section)\n")
    }
    
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        //remove annotations if all sections are closed
        print("WILL CLOSE SECTION: \(section)\n")
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        print("DID CLOSE SECTION: \(section)")
//        mapView.removeOverlays(mapView.overlays)
//        mapView.removeAnnotations(mapView.annotations)
    }
    
    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        return true
    }
}
