//
//  Subscription.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 5/24/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Firebase
import FirebaseFirestore
import CoreLocation

struct Subscription: iTask {
    var live: Int
    var grassLength: Task.GrassLength? {
        return .maintained
    }
    var when: Task.When? {
        return .schedule
    }
    var id: String!
    let customerId: String
    let address: String
    let location: CLLocation
    let createdAt: Date
    var frequency: Task.Frequency?
    var lawnSize: Task.LawnSize?
    var price: Price
    var scheduleAt: Date
    var nextTaskScheduleAt: Date?
    //var skipNextTask: Bool
    
    init(task: Task) {
        self.live = task.live
        self.customerId = task.customerId
        self.address = task.address
        self.location = task.location
        self.createdAt = task.createdAt
        self.frequency = task.frequency!
        self.lawnSize = task.lawnSize!
        self.scheduleAt = task.scheduleAt
        self.nextTaskScheduleAt = task.scheduleAt
        let pricing = PricingDataProvider.shared.rx_pricingLawnService.value!
        self.price = pricing.regularPrice(forTask: task)
    }

    init(dictionary: [String: Any]) {
        live = (dictionary[K.Firestore.Collection.Subscriptions.Field.Live] as? Int) ?? 0
        id = dictionary[K.Firestore.Collection.Subscriptions.Field.Id] as! String
        customerId = dictionary[K.Firestore.Collection.Subscriptions.Field.CustomerId] as! String
        address = dictionary[K.Firestore.Collection.Subscriptions.Field.Address] as! String
        location = (dictionary[K.Firestore.Collection.Subscriptions.Field.Location] as! GeoPoint).location
        let createdTimestamp = dictionary[K.Firestore.Collection.Subscriptions.Field.CreatedAt] as! Timestamp
        createdAt = createdTimestamp.dateValue()
        frequency = Task.Frequency(rawValue: dictionary[K.Firestore.Collection.Subscriptions.Field.Frequency] as! String)!
        lawnSize = Task.LawnSize(rawValue: dictionary[K.Firestore.Collection.Subscriptions.Field.LawnSize] as! String)!
        price = Price(cents: dictionary[K.Firestore.Collection.Subscriptions.Field.Price] as! Int)
        let scheduleTimestamp = dictionary[K.Firestore.Collection.Subscriptions.Field.ScheduleAt] as! Timestamp
        scheduleAt = scheduleTimestamp.dateValue()
        let nextTaskScheduleAt = dictionary[K.Firestore.Collection.Subscriptions.Field.NextTaskScheduleAt] as? Timestamp
        self.nextTaskScheduleAt = nextTaskScheduleAt?.dateValue()
    }
    
    static func nextScheduledDate(for subscription: Subscription) -> Date {
        let scheduleAt = subscription.scheduleAt
        var dateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: scheduleAt)
        dateComponents.calendar = Calendar.current
        if subscription.frequency == .weekly {
            dateComponents.day! += 7
        } else if subscription.frequency == .biweekly {
            dateComponents.day! += 14
        }
        let date = dateComponents.date!
        if date.timeIntervalSince1970 > Date().timeIntervalSince1970 {
            return date
        } else {
            var editedSubscription = subscription
            editedSubscription.scheduleAt = date
            return nextScheduledDate(for: editedSubscription)
        }
    }
    
    var toAny: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[K.Firestore.Collection.Subscriptions.Field.Live] = live
        dictionary[K.Firestore.Collection.Subscriptions.Field.Id] = id
        dictionary[K.Firestore.Collection.Subscriptions.Field.CustomerId] = customerId
        dictionary[K.Firestore.Collection.Subscriptions.Field.Address] = address
        dictionary[K.Firestore.Collection.Subscriptions.Field.Location] = location.geoPoint
        dictionary[K.Firestore.Collection.Subscriptions.Field.CreatedAt] = createdAt
        dictionary[K.Firestore.Collection.Subscriptions.Field.Frequency] = frequency!.rawValue
        dictionary[K.Firestore.Collection.Subscriptions.Field.LawnSize] = lawnSize!.rawValue
        dictionary[K.Firestore.Collection.Subscriptions.Field.Price] = price.value
        dictionary[K.Firestore.Collection.Subscriptions.Field.ScheduleAt] = scheduleAt
        dictionary[K.Firestore.Collection.Subscriptions.Field.NextTaskScheduleAt] = nextTaskScheduleAt
        return dictionary
    }
}
