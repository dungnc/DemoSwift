//
//  LocationHelper.swift
//  Find Me
//
//  Created by Nguyen Chi Dung on 9/25/17.
//  Copyright © 2017 Nguyen Chi Dung. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift

class LocationHelper: NSObject, CLLocationManagerDelegate {

    static let shared = LocationHelper()
    var authorizationStatusChanged: ((CLAuthorizationStatus) -> ())?
    var rx_currentLocation: Variable<CLLocation?>!
    fileprivate var locationManager: CLLocationManager
    fileprivate var isLocationUpToDate: Bool = false
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 50
        super.init()
        rx_currentLocation = Variable(nil)
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    open func startTrackingCurrentLocation() {
        UserDefaults.standard.set(true, forKey: K.UserDefaults.NeedsCurrentLocationTracking)
        UserDefaults.standard.synchronize()
    }
    
    open func stopTrackingCurrentLocation() {
        isLocationUpToDate = false
        rx_currentLocation.value = nil
        ProvidersDataProvider.shared.sendCurrentLocation(nil, forProvider: Provider.current!)
        UserDefaults.standard.set(false, forKey: K.UserDefaults.NeedsCurrentLocationTracking)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let authorizationStatusChanged = authorizationStatusChanged {
            authorizationStatusChanged(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        //print("\(#function)\(location)")
        if let location = location, let provider = Provider.current {
            if isLocationUpToDate {
                rx_currentLocation.value = location
                if UserDefaults.standard.bool(forKey: K.UserDefaults.NeedsCurrentLocationTracking) {
                    ProvidersDataProvider.shared.sendCurrentLocation(location, forProvider: provider)
                }
            } else {
                isLocationUpToDate = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(#function) \(error)")
    }
}
