//
//  Provider.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 4/15/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import CoreLocation
import Firebase

struct Provider: TDUser {
    static var current: Provider? {
        didSet {
            current?.save()
        }
    }
    var live: Int
    var id: String
    var name: String
    var currentLocation: CLLocation?
    var locationTimestamp: Date?
    var email: String
    var phone: String
    var photoUrl: String?
    var pushToken: String?
    
    init(id: String, email: String, name: String, phone: String) {
        self.live = K.App.Live
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
    }
    
    init(dictionary: [String: Any]) {
        id = dictionary[K.Firestore.Collection.Providers.Field.Id] as! String
        name = dictionary[K.Firestore.Collection.Providers.Field.Name] as! String
        email = dictionary[K.Firestore.Collection.Providers.Field.Email] as! String
        phone = dictionary[K.Firestore.Collection.Providers.Field.Phone] as! String
        photoUrl = dictionary[K.Firestore.Collection.Providers.Field.PhotoUrl] as? String
        let geoPoint = dictionary[K.Firestore.Collection.Providers.Field.CurrentLocation] as? GeoPoint
        currentLocation = geoPoint?.location
        let locationTimestamp = dictionary[K.Firestore.Collection.Providers.Field.LocationTimestamp] as? Timestamp
        self.locationTimestamp = locationTimestamp?.dateValue()
        pushToken = dictionary[K.Firestore.Collection.Users.Field.PushToken] as? String
        live = (dictionary[K.Firestore.Collection.Users.Field.Live] as? Int) ?? 0
    }
    
    var toAny: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[K.Firestore.Collection.Providers.Field.Id] = id
        dictionary[K.Firestore.Collection.Providers.Field.Name] = name
        dictionary[K.Firestore.Collection.Providers.Field.Email] = email
        dictionary[K.Firestore.Collection.Providers.Field.Phone] = phone
        dictionary[K.Firestore.Collection.Providers.Field.PhotoUrl] = photoUrl
        dictionary[K.Firestore.Collection.Users.Field.PushToken] = pushToken
        dictionary[K.Firestore.Collection.Users.Field.Live] = live
        return dictionary
    }
    
    func save() {
        UserDefaults.standard.set(toAny, forKey: K.UserDefaults.LoggedInUser)
        UserDefaults.standard.synchronize()
    }
    
    static func load() -> Provider? {
        var user: Provider?
        if let dictionary = UserDefaults.standard.object(forKey: K.UserDefaults.LoggedInUser) as? [String: Any] {
            user = Provider(dictionary: dictionary)
        }
        return user
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        PushNotificationManager.shared.unregister()
        UserDefaults.standard.removeObject(forKey: K.UserDefaults.LoggedInUser)
        UserDefaults.standard.synchronize()
        Provider.current = nil
    }
}
