//
//  Customer.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/16/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Firebase
import CoreLocation

struct Customer: TDUser, CustomStringConvertible {
    static var current: Customer?  {
        didSet {
            current?.save()
        }
    }
    var live: Int
    var id: String
    var email: String
    var name: String
    var phone: String
    var address: String?
    var location: CLLocation?
    var photoUrl: String?
    var stripeCustomerId: String?
    var cards: [Card]?
    var pushToken: String?

    init(id: String, email: String, name: String, phone: String) {
        self.live = K.App.Live
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
    }
    
    init(dictionary: [String: Any]) {
        id = dictionary[K.Firestore.Collection.Customers.Field.Id] as! String
        email = dictionary[K.Firestore.Collection.Customers.Field.Email] as! String
        name = dictionary[K.Firestore.Collection.Customers.Field.Name] as! String
        phone = dictionary[K.Firestore.Collection.Customers.Field.Phone] as! String
        address = dictionary[K.Firestore.Collection.Customers.Field.Address] as? String
        let geoPoint = dictionary[K.Firestore.Collection.Customers.Field.Location] as? GeoPoint
        location = geoPoint?.location
        photoUrl = dictionary[K.Firestore.Collection.Customers.Field.PhotoUrl] as? String
        stripeCustomerId = dictionary[K.Firestore.Collection.Customers.Field.StripeCustomerId] as? String
        if let cardsDictionaries = dictionary[K.Firestore.Collection.Customers.Field.Cards] as? [[String: Any]] {
            cards = cardsDictionaries.map({ Card(dictionary: $0 ) })
        }
        pushToken = dictionary[K.Firestore.Collection.Users.Field.PushToken] as? String
        live = (dictionary[K.Firestore.Collection.Users.Field.Live] as? Int) ?? 0
    }
    
    var toAny: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[K.Firestore.Collection.Customers.Field.Id] = id
        dictionary[K.Firestore.Collection.Customers.Field.Email] = email
        dictionary[K.Firestore.Collection.Customers.Field.Name] = name
        dictionary[K.Firestore.Collection.Customers.Field.Phone] = phone
        dictionary[K.Firestore.Collection.Customers.Field.Address] = address
        dictionary[K.Firestore.Collection.Customers.Field.Location] = location?.geoPoint
        dictionary[K.Firestore.Collection.Customers.Field.PhotoUrl] = photoUrl
        dictionary[K.Firestore.Collection.Customers.Field.StripeCustomerId] = stripeCustomerId
        dictionary[K.Firestore.Collection.Customers.Field.Cards] = cards?.map({ $0.toAny })
        dictionary[K.Firestore.Collection.Users.Field.PushToken] = pushToken
        dictionary[K.Firestore.Collection.Users.Field.Live] = live
        return dictionary
    }
    
    func save() {
        var dictionary = toAny
        if let location = location {
            dictionary["location"] = nil
            dictionary["latitude"] = location.coordinate.latitude
            dictionary["longitude"] = location.coordinate.latitude
        }
        UserDefaults.standard.set(dictionary, forKey: K.UserDefaults.LoggedInUser)
        UserDefaults.standard.synchronize()
    }
    
    static func load() -> Customer? {
        var customer: Customer?
        if var dictionary = UserDefaults.standard.object(forKey: K.UserDefaults.LoggedInUser) as? [String: Any] {
            if let latitude = dictionary["latitude"] as? CLLocationDegrees,
                let longitude = dictionary["longitude"] as? CLLocationDegrees {
                dictionary["location"] = GeoPoint(latitude: latitude, longitude: longitude)
            }
            customer = Customer(dictionary: dictionary)
        }
        return customer
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        PushNotificationManager.shared.unregister()
        UserDefaults.standard.set(nil, forKey: K.UserDefaults.LoggedInUser)
        UserDefaults.standard.synchronize()
        Customer.current = nil
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        var string = ""
        string += "Email: \(email)\n"
        string += "Name: \(name)\n"
        string += "Id: \(id)\n"
        string += "location: \(location)\n"
        return string
    }
    
    struct Card {
        let id: String
        let last4: String
        
        init(id: String, last4: String) {
            self.id = id
            self.last4 = last4
        }
        
        init(dictionary: [String: Any]) {
            id = dictionary["id"] as! String
            last4 = dictionary["last4"] as! String
        }
        
        var toAny: [String: Any] {
            var dictionary: [String: Any] = [:]
            dictionary["id"] = id
            dictionary["last4"] = last4
            return dictionary
        }
    }
}
