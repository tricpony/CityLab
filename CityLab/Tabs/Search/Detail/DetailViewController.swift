//
//  DetailViewController.swift
//  CityLab
//
//  Created by aarthur on 11/10/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var mattImageView: UIImageView!
    @IBOutlet weak var emptySelectionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var city: City? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let safeCity = self.city {
            let initialLocation = CLLocation(latitude: safeCity.lat, longitude: safeCity.lon)
            centerMapOnLocation(location: initialLocation);
        }else
        {
            //this supports the regular size class to display a placeholder view when no city is selected
            mapView.isHidden = true
            emptySelectionLabel.isHidden = false
            mattImageView.isHidden = false
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        let annotation = MKPointAnnotation()
        let regionRadius: CLLocationDistance = 30000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.addAnnotation(annotation)
    }

}
