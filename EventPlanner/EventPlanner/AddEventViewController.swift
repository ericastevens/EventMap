//
//  AddEventViewController.swift
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
import Contacts

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class AddEventViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, HandleMapSearch{
    
    
    // MARK: - Stored Properties
    var eventName = ""
    var eventAddress = "" {
        didSet {
            
            
            enterEventInfoLabel.text = eventAddress
            enterEventInfoLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        }
    }
    var eventCity = ""
    var eventType = ""
    var latitude = 0.0
    var longitude = 0.0
    
    // MARK: - MKLocalSearch
    var selectedLocationPin: MKPlacemark?
    
    var resultController: UISearchController!
    
    
    let locationManager: CLLocationManager = {
        let locMan = CLLocationManager()
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.requestWhenInUseAuthorization()
        locMan.distanceFilter = 50.0
        return locMan
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    // MARK: - Core Data
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Lazy UI Views
    lazy var overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        return view
    }()
    
    lazy var enterEventInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Enter Event Information"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightThin)
        label.textColor = .white
        return label
    }()
    
    
    
    lazy var formView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var enterEventNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Event Name:"
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var enterEventNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.placeholder = "Enter Event Name"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        return tf
    }()
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == enterEventNameTextField {
            self.eventName = textField.text!
            print("EVENTNAME: \(self.eventName)")
        } else {
            print("EVENT NAME NOT CAPTURED!")
        }
        
    }
 
    lazy var enterStartLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Start:"
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var enterStartTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.placeholder = "Set Start Time"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(AddEventViewController.chooseStartTimeFromDatePicker), for: .editingDidBegin)
        return tf
    }()
    
    lazy var enterEndLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "End:"
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var enterEndTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.placeholder = "Set End Time"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(AddEventViewController.chooseEndTimeFromDatePicker), for: .editingDidBegin)
        return tf
    }()
    
    lazy var enterTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Type:"
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var enterTypeTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.placeholder = "Select Event Type"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(AddEventViewController.chooseTypeFromPicker), for: .editingDidBegin)
        return tf
    }()
    
    func chooseTypeFromPicker(sender: UITextField) {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        
        
        self.view.addSubview(pickerView)
        
        _ = [
            pickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            pickerView.leadingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: self.formView.bottomAnchor),
            pickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            ].map { $0.isActive = true }
    }
    
    
    func chooseStartTimeFromDatePicker(sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.minimumDate = Date()
        datePickerView.minuteInterval = 5
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddEventViewController.datePickerValueChangedForStartDate), for: .valueChanged)
    }
    
    func datePickerValueChangedForStartDate(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        enterStartTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func chooseEndTimeFromDatePicker(sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        sender.inputView = datePickerView
        datePickerView.minuteInterval = 5
        datePickerView.addTarget(self, action: #selector(AddEventViewController.datePickerValueChangedForEndDate), for: .valueChanged)
    }
    
    func datePickerValueChangedForEndDate(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        enterEndTextField.text = dateFormatter.string(from: sender.date)
    }
    
    
    let addressSearchTVC = EventLocationSearchTableViewController()
    let eventVC = EventViewController()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupConstraints()
        
        locationManager.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddEventViewController.doneButtonPressed))
        
        
        resultController = UISearchController(searchResultsController: addressSearchTVC)
        resultController.searchResultsUpdater = addressSearchTVC
        let searchBar = resultController!.searchBar
        searchBar.placeholder = "Search Addresses"
        navigationItem.titleView = resultController?.searchBar
        resultController.hidesNavigationBarDuringPresentation = false
        resultController.dimsBackgroundDuringPresentation = true
        
        
        definesPresentationContext = true
        
        addressSearchTVC.mapView = self.mapView
        
        addressSearchTVC.handleMapSearchDelegate = self
        
    }
    
    
    
    func doneButtonPressed() {
        
        //ok/save event action button pressed
        //check for empty values before saving to context
        if (self.enterStartTextField.text?.characters.count)! > 0 &&
            (self.enterEndTextField.text?.characters.count)! > 0 && (self.enterTypeTextField.text?.characters.count)! > 0 && (self.enterEventNameTextField.text?.characters.count)! > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            
            
            self.mainContext.performAndWait {
                let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: self.mainContext) as! Event
                
                if let newEventStartDate = dateFormatter.date(from: self.enterStartTextField.text!),
                    let newEventEndDate = dateFormatter.date(from: self.enterEndTextField.text!) {
                    
                    //set values for entity attributes here
                    newEvent.startDate = newEventStartDate as NSDate
                    newEvent.endDate = newEventEndDate as NSDate
                    newEvent.address = self.eventAddress
                    newEvent.latitude = self.latitude
                    newEvent.longitude = self.longitude
                    newEvent.event = self.eventName //returning empty string
                    newEvent.city = self.eventCity
                    newEvent.type = self.eventType
                    
                }
            }
            do {
                try self.mainContext.save()
                self.mainContext.parent?.performAndWait {
                    do {
                        try self.mainContext.parent?.save()
                    }
                    catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
                
            }
            catch let error {
                print(error)
            }
            
            DispatchQueue.main.async {
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            
            //cancel button pressed
            //confirm: are you sure
            //pop to rootViewController
            
            //edit event
            //dismiss alert, retun to addEventViewController
            
        } else {
            //if fields are missisng
            let someFieldsBlankAlert = UIAlertController(title: "Missing Info", message: "Please fill in all fields to continue", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            someFieldsBlankAlert.addAction(okAction)
            self.present(someFieldsBlankAlert, animated: true, completion: nil)
            
            //add a guard for missing address
        }
        
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpanMake(0.05,0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    // MARK: HandleMapSearch
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache pin
        selectedLocationPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        // add new pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
            self.eventCity = city
            
            // update coreData variable
            self.longitude = placemark.coordinate.longitude
            self.latitude = placemark.coordinate.latitude
            let addressDictionary = placemark.addressDictionary as! Dictionary<NSObject,AnyObject>
            let postalAddress = CNMutablePostalAddress()
            print("POSTAL ADDRESS: \(postalAddress)")
            postalAddress.street = addressDictionary["Street" as NSObject] as? String ?? ""
            postalAddress.state = addressDictionary["State" as NSObject] as? String ?? ""
            postalAddress.city = addressDictionary["City" as NSObject] as? String ?? ""
            postalAddress.postalCode = addressDictionary["ZIP" as NSObject] as? String ?? ""
            self.eventAddress = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            print("EVENT ADDRESS: \(eventAddress)")
            
            mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(placemark.coordinate, span)
            mapView.setRegion(region, animated: true)
            
            //add label to pin
        }
        
    }
    
    // MARK: - View Setup Functions
    
    func setupViewHierarchy() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(mapView)
        self.view.addSubview(overlayView)
        self.overlayView.addSubview(enterEventInfoLabel)
        self.overlayView.addSubview(formView)
        self.formView.addSubview(enterEventNameLabel)
        self.formView.addSubview(enterEventNameTextField)
        
        self.formView.addSubview(enterStartLabel)
        self.formView.addSubview(enterStartTextField)
        self.formView.addSubview(enterEndLabel)
        self.formView.addSubview(enterEndTextField)
        self.formView.addSubview(enterTypeLabel)
        self.formView.addSubview(enterTypeTextField)
    }
    
    func setupConstraints() {
        _ = [
            // mapView
            self.mapView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
            self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4),
            self.mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            //gray overlay view
            overlayView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6),
            overlayView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            overlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: self.mapView.bottomAnchor),
            overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            //top label
            enterEventInfoLabel.centerXAnchor.constraint(equalTo: self.overlayView.centerXAnchor),
            enterEventInfoLabel.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: 20),
            
            //form view
            formView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            formView.heightAnchor.constraint(equalTo: self.overlayView.heightAnchor, multiplier: 0.55),
            formView.centerXAnchor.constraint(equalTo: self.overlayView.centerXAnchor),
            formView.topAnchor.constraint(equalTo: enterEventInfoLabel.bottomAnchor, constant: 25),
            
            //name label & text field
            enterEventNameLabel.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16.0),
            enterEventNameLabel.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            enterEventNameTextField.topAnchor.constraint(equalTo: enterEventNameLabel.bottomAnchor, constant: 8.0),
            enterEventNameTextField.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            enterEventNameTextField.widthAnchor.constraint(equalTo: formView.widthAnchor, multiplier: 0.7),
            
            //start date label & text field
            enterStartLabel.topAnchor.constraint(equalTo: enterEventNameTextField.bottomAnchor, constant: 16),
            enterStartLabel.centerXAnchor.constraint(equalTo: enterStartTextField.centerXAnchor),
            enterStartTextField.topAnchor.constraint(equalTo: enterStartLabel.bottomAnchor, constant: 8.0),
            enterStartTextField.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 8.0),
            enterStartTextField.widthAnchor.constraint(equalTo: formView.widthAnchor, multiplier: 0.45),
            
            //end date label & text field
            enterEndLabel.topAnchor.constraint(equalTo: enterEventNameTextField.bottomAnchor, constant: 16),
            enterEndLabel.centerXAnchor.constraint(equalTo: enterEndTextField.centerXAnchor),
            enterEndTextField.topAnchor.constraint(equalTo: enterEndLabel.bottomAnchor, constant: 8.0),
            enterEndTextField.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -8.0),
            enterEndTextField.widthAnchor.constraint(equalTo: formView.widthAnchor, multiplier: 0.45),
            
            //type label & text field
            enterTypeLabel.topAnchor.constraint(equalTo: enterEndTextField.bottomAnchor, constant: 16.0),
            enterTypeLabel.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            enterTypeTextField.topAnchor.constraint(equalTo: enterTypeLabel.bottomAnchor, constant: 8.0),
            enterTypeTextField.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            enterTypeTextField.widthAnchor.constraint(equalTo: formView.widthAnchor, multiplier: 0.7)
            ].map { $0.isActive = true }
    }
    
    // MARK: UIPickerView Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventType.eventArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventType.eventArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.enterTypeTextField.text = EventType.eventArr[row]
        self.eventType = EventType.eventArr[row]
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        self.resignFirstResponder()
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
