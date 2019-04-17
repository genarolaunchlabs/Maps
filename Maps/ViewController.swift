//
//  ViewController.swift
//  Maps
//
//  Created by AA22 on 01/04/2019.
//  Copyright © 2019 AA22. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import what3words
import CoreLocation

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    var mapView : GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = GMSMapView()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView?.tintColor = UIColor.clear
        
        
        mapView?.delegate = self
        view = mapView
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            // 4
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }


}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let projection = mapView.projection.visibleRegion()
        
        let coor1 = CLLocation(latitude: projection.farLeft.latitude, longitude: projection.farLeft.longitude)
        let coor2 = CLLocation(latitude: projection.nearLeft.latitude, longitude: projection.nearLeft.longitude)
        
        let distanceInMeters = coor1.distance(from: coor2)
        
        if distanceInMeters <= 230 {
            print("good: \(distanceInMeters)")
            W3wGeocoder.setup(with: "RHO7FXIZ")
            
            W3wGeocoder.shared.gridSection(south_lat: projection.nearRight.latitude, west_lng: projection.nearRight.longitude, north_lat: projection.farLeft.latitude, east_lng: projection.farLeft.longitude) { (lines, error) in
                DispatchQueue.main.async {
                    mapView.clear()
                    
                    for (index, item) in (lines?.enumerated())! {
                        let path = GMSMutablePath()
                        path.add(item.start)
                        path.add(item.end)
                        
//                        print("start \(item.start)")
//                        print("end \(item.end)")
//                        print("index \(index)")
//                        print("=============================================================================")
                        
                        let line = GMSPolyline(path: path)
                        line.strokeColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                        line.map = mapView
                    }
                    if let location = mapView.myLocation {
                        let position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        let marker = GMSMarker()
                        marker.position = position
//                        marker.snippet = "Info window text"
                        marker.icon = UIImage(named: "pin")
                        marker.setIconSize(scaledToSize: .init(width: 40, height: 50))
                        marker.map = mapView
                        mapView.tintColor = UIColor.clear
                    }
                }
            }
        }else{
            print("bad: \(distanceInMeters)")
            mapView.clear()
        }
    }
}

// MARK: - CLLocationManagerDelegate
//1
extension ViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        
//        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        
        
        
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        print("location \(location)")
        
        // 7
        mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
        mapView?.tintColor = UIColor.clear
    }
}

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}

