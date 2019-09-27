//
//  GeoPoint+CLLocation.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/13/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Firebase
import CoreLocation
import Firebase
import FirebaseFirestore

extension GeoPoint {
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension CLLocation {
    var geoPoint: GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
