//
//  EventLocationSearchTableViewController.swift
//  EventPlanner
//
//  Created by Erica Y Stevens on 1/16/17.
//  Copyright © 2017 Tea. All rights reserved.
//

import UIKit

import UIKit
import MapKit
import Contacts

// https://github.com/ThornTechPublic/MapKitTutorial

class EventLocationSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let cellIdentifier = "searchCellIdentifier"
    
    
    // MARK: - Map
    weak var handleMapSearchDelegate: HandleMapSearch?
    var mapView: MKMapView?
    var matchingLocations: [MKMapItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView
        //var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    //Method 1 to get address String:
    func parseAddress(selectedItem:MKPlacemark) -> String {
        
        let addressDictionary = selectedItem.addressDictionary as! Dictionary<NSObject,AnyObject>
        
        let address = CNMutablePostalAddress()
        
        address.street = addressDictionary["Street" as NSObject] as? String ?? ""
        address.state = addressDictionary["State" as NSObject] as? String ?? ""
        address.city = addressDictionary["City" as NSObject] as? String ?? ""
        address.postalCode = addressDictionary["ZIP" as NSObject] as? String ?? ""
        
        print(CNPostalAddressFormatter.string(from: address, style: .mailingAddress).replacingOccurrences(of: "\n", with: ", "))
        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress).replacingOccurrences(of: "\n", with: ", ")
        
        //Method 2 to get address String:
        //        // put a space between "4" and "Melrose Place"
        //        let firstSpace = (selectedItem.subThoroughfare != nil &&
        //            selectedItem.thoroughfare != nil) ? " " : ""
        //
        //        // put a comma between street and city/state
        //        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
        //            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        //
        //        // put a space between "Washington" and "DC"
        //        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
        //            selectedItem.administrativeArea != nil) ? " " : ""
        //
        //        let addressLine = String(
        //            format:"%@%@%@%@%@%@%@",
        //            // street number
        //            selectedItem.subThoroughfare ?? "",
        //            firstSpace,
        //            // street name
        //            selectedItem.thoroughfare ?? "",
        //            comma,
        //            // city
        //            selectedItem.locality ?? "",
        //            secondSpace,
        //            // state
        //            selectedItem.administrativeArea ?? "",
        //            // zip code
        //            selectedItem.countryCode ?? ""
        //        )
        //        print(addressLine)
        //
        //        return addressLine
    }
    
    //Method 3 to get address String:
    //    Convert to the newer CNPostalAddress
    //    func postalAddressFromAddressDictionary(_ addressdictionary: Dictionary<NSObject,AnyObject>) -> CNMutablePostalAddress {
    //        let address = CNMutablePostalAddress()
    //
    //        address.street = addressdictionary["Street" as NSObject] as? String ?? ""
    //        address.state = addressdictionary["State" as NSObject] as? String ?? ""
    //        address.city = addressdictionary["City" as NSObject] as? String ?? ""
    //        address.country = addressdictionary["Country" as NSObject] as? String ?? ""
    //        address.postalCode = addressdictionary["ZIP" as NSObject] as? String ?? ""
    //
    //        return address
    //    }
    //
    //    // Create a localized address string from an Address Dictionary
    //    func localizedStringForAddressDictionary(addressDictionary: Dictionary<NSObject,AnyObject>) -> String {
    //        return CNPostalAddressFormatter.string(from: postalAddressFromAddressDictionary(addressDictionary), style: .mailingAddress)
    //    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        let selectedLocation = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = selectedLocation.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedLocation)
        
        print("ADDRESS: \(parseAddress(selectedItem: selectedLocation))")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = matchingLocations[indexPath.row].placemark
        
        let instance = AddEventViewController()
        instance.eventAddress = "\(selectedLocation)"
        
        
        print("SELECTED LOCATION \(selectedLocation)")
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedLocation)
        
        dismiss(animated: true, completion: nil)
    }
    
}
