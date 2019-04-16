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
    var oldLayer = TileLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey("AIzaSyBxxEUEvLuvaqemyRo4AmKF90QTVbiC6po")
        GMSPlacesClient.provideAPIKey("AIzaSyBxxEUEvLuvaqemyRo4AmKF90QTVbiC6po")
        
        let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let camera = GMSCameraPosition.camera(withLatitude: 37.621262, longitude: -122.378945, zoom: 20)
        
        let mapView = GMSMapView.map(withFrame: rect, camera: camera)
        
        mapView.delegate = self
        
        
        
        
        
        view = mapView
        
//        let layer = TestTileLayer()
//        layer.tileSize = 50
//        layer.map = mapView
    }

}

class TileLayer: GMSSyncTileLayer {
//    private var coloredTile: UIImage
//    private var blankTile: UIImage
//    override init() {
//        print("Tile layer initialized")
//        coloredTile = UIImage(named: "tile-colored")!
//        blankTile = UIImage(named: "tile")!
//    }
    override func tileFor(x: UInt, y: UInt, zoom: UInt) -> UIImage? {
        // render an image every tile.
        
        if (x % 3 == Int.random(in: 0 ... 5)) {
            return UIImage(named: "tile-colored")
//            return coloredTile
        } else {
            return UIImage(named: "tile")
//            return blankTile
        }
    }
}

extension ViewController: GMSMapViewDelegate {
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
//                        path.add(item.end)
//                        print("end \(item.end)")
//                        print("index \(index)")
//                        print("=============================================================================")
                        
                        let line = GMSPolyline(path: path)
                        line.strokeColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                        line.map = mapView
                    }
                }
            }
        }else{
            print("bad: \(distanceInMeters)")
            mapView.clear()
        }
        
        
        
        let zoom = mapView.camera.zoom
//        mapView.clear()
        if zoom > 15 {
//            let layer = TileLayer()
//            layer.tileSize = 30
//            layer.map = mapView
//            oldLayer = layer
//
//            let southWest = CLLocationCoordinate2D(latitude: 40.712216, longitude: -74.22655)
//            let northEast = CLLocationCoordinate2D(latitude: 40.773941, longitude: -74.12544)
//            let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
//
//            // Image from http://www.lib.utexas.edu/maps/historical/newark_nj_1922.jpg
//            let icon = UIImage(named: "tile-colored")
//
//            let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
//            overlay.bearing = 0
//            overlay.map = mapView
            
            
        }else{
//            mapView.clear()
        }
//        print("map zoom is ",String(zoom))
    }
}
