//
//  MapCache.swift
//  Public Eyes
//
//  Created by Fitsyu  on 02/11/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class MapCache {
    
    var memory: [LatLng:UIImage] = [:]
    
    func thumbnail(for location: CLLocationCoordinate2D, view: UIImageView?) {
        
        let key = LatLng(lat: location.latitude, lng: location.longitude)
        
        if let image = memory[key] {
            
            DispatchQueue.main.async {
                view?.image = image
            }
            
            
        } else {
            
            let options = MKMapSnapshotter.Options()
            
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            
            options.region = region
            
            options.mapType = .standard
            options.scale = UIScreen.main.scale
            options.size = CGSize(width: 300, height: 300)
            
            options.showsBuildings = true
            
            let snapshotter = MKMapSnapshotter(options: options)
            
            print("getting location snapshot..")
            snapshotter.start { (snapshot: MKMapSnapshotter.Snapshot?, error: Error?) in
                
                print("done getting location snapshot.")
                if let error = error { print (error.localizedDescription) }
                
                guard let image = snapshot?.image else { return }
                                
                DispatchQueue.main.async {
                    view?.image = image
                }
                
                self.memory[key] = image
            }
        }
        
    }
    
    
    static let shared = MapCache()
    private init() {}
}


struct LatLng: Hashable {
    var lat: Double
    var lng: Double
}
