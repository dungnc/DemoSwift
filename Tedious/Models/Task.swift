//
//  Task.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/11/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Firebase
import FirebaseFirestore
import CoreLocation

struct Task: iTask, CustomStringConvertible {
    var live: Int
    var id: String!
    var subscriptionId: String?
    let customerId: String
    let address: String
    let location: CLLocation
    var status: Status
    let createdAt: Date
    var grassLength: GrassLength?
    var frequency: Frequency?
    var lawnSize: LawnSize?
    var when: When?
    var startedAt: Date?
    var photoUrl: String?
    var duration: TimeInterval?
    var scheduleAt: Date
    var providerId: String?
    var receipt: Receipt!
    
    init(live: Int, customerId: String, address: String, location: CLLocation, lawnSize: Task.LawnSize?) {
        self.live = live
        self.customerId = customerId
        self.status = .pending
        self.address = address
        self.location = location
        self.createdAt = Date()
        self.scheduleAt = Date()
        self.lawnSize = lawnSize
    }
    
    static func nextTask(fromSubscription subscription: Subscription) -> Task {
        var newTask = Task(live: subscription.live,
                           customerId: subscription.customerId,
                           address: subscription.address,
                           location: subscription.location,
                           lawnSize: subscription.lawnSize)
        newTask.subscriptionId = subscription.id
        newTask.grassLength = subscription.grassLength
        newTask.frequency = subscription.frequency
        newTask.when = subscription.when
        newTask.scheduleAt = Subscription.nextScheduledDate(for: subscription)
        newTask.receipt = Receipt(item: Receipt.Item.LawnService, price: subscription.price)
        return newTask
    }
    
    init(dictionary: [String: Any]) {
        live = (dictionary[K.Firestore.Collection.Tasks.Field.Live] as? Int) ?? 0
        id = dictionary[K.Firestore.Collection.Tasks.Field.Id] as! String
        subscriptionId = dictionary[K.Firestore.Collection.Tasks.Field.SubscriptionId] as? String
        providerId = dictionary[K.Firestore.Collection.Tasks.Field.ProviderId] as? String
        customerId = dictionary[K.Firestore.Collection.Tasks.Field.CustomerId] as! String
        address = dictionary[K.Firestore.Collection.Tasks.Field.Address] as! String
        status = Status(rawValue: dictionary[K.Firestore.Collection.Tasks.Field.Status] as! Int)!
        grassLength = GrassLength(rawValue: dictionary[K.Firestore.Collection.Tasks.Field.GrassLength] as! String)
        createdAt = (dictionary[K.Firestore.Collection.Tasks.Field.CreatedAt] as! Timestamp).dateValue()
        location = (dictionary[K.Firestore.Collection.Tasks.Field.Location] as! GeoPoint).location
        startedAt = (dictionary[K.Firestore.Collection.Tasks.Field.StartedAt] as? Timestamp)?.dateValue()
        photoUrl = dictionary[K.Firestore.Collection.Tasks.Field.PhotoUrl] as? String
        duration = dictionary[K.Firestore.Collection.Tasks.Field.Duration] as? TimeInterval
        scheduleAt = (dictionary[K.Firestore.Collection.Tasks.Field.ScheduleAt] as! Timestamp).dateValue()
        frequency = Frequency(rawValue: dictionary[K.Firestore.Collection.Tasks.Field.Frequency] as! String)
        lawnSize = LawnSize(rawValue: dictionary[K.Firestore.Collection.Tasks.Field.LawnSize] as! String)
        when = When(rawValue: dictionary[K.Firestore.Collection.Tasks.Field.When] as! String)
        receipt = Receipt(dictionary: dictionary[K.Firestore.Collection.Tasks.Field.Receipt] as? [String: Any])
    }
    
    var toAny: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[K.Firestore.Collection.Tasks.Field.Live] = live
        dictionary[K.Firestore.Collection.Tasks.Field.Id] = id
        dictionary[K.Firestore.Collection.Tasks.Field.SubscriptionId] = subscriptionId
        dictionary[K.Firestore.Collection.Tasks.Field.ProviderId] = providerId
        dictionary[K.Firestore.Collection.Tasks.Field.CustomerId] = customerId
        dictionary[K.Firestore.Collection.Tasks.Field.Address] = address
        dictionary[K.Firestore.Collection.Tasks.Field.Status] = status.rawValue
        dictionary[K.Firestore.Collection.Tasks.Field.CreatedAt] = createdAt
        dictionary[K.Firestore.Collection.Tasks.Field.Location] = location.geoPoint
        dictionary[K.Firestore.Collection.Tasks.Field.StartedAt] = startedAt
        dictionary[K.Firestore.Collection.Tasks.Field.PhotoUrl] = photoUrl
        dictionary[K.Firestore.Collection.Tasks.Field.Duration] = duration
        dictionary[K.Firestore.Collection.Tasks.Field.GrassLength] = grassLength?.rawValue
        dictionary[K.Firestore.Collection.Tasks.Field.ScheduleAt] = scheduleAt
        dictionary[K.Firestore.Collection.Tasks.Field.Frequency] = frequency?.rawValue
        dictionary[K.Firestore.Collection.Tasks.Field.LawnSize] = lawnSize?.rawValue
        dictionary[K.Firestore.Collection.Tasks.Field.When] = when?.rawValue
        dictionary[K.Firestore.Collection.Tasks.Field.Receipt] = receipt.toAny
        return dictionary
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        var string = ""
        string += "ID: \(id ?? "-")\n"
        string += "Status: \(status)\n"
        string += "Address: \(address)\n"
        string += "Provider ID: \(providerId ?? "-")\n"
        string += "Schedule: \(scheduleAt.description)\n"
        string += "CreatedAt: \(createdAt)\n"
        string += "Frequency: \(frequency?.rawValue ?? "-")\n"
        string += "Lawn Size: \(lawnSize?.rawValue ?? "-")\n"
        return string
    }
    
    var isEnded: Bool {
        return [Status.canceledByProvider, Status.canceledByCustomer, Status.completed].contains(where: { $0 == self.status })
    }
    
    var isRecurring: Bool {
        return [Frequency.weekly, Frequency.biweekly].contains(where: { $0 == self.frequency })
    }
    
    enum Status: Int, CustomStringConvertible {
        case pending = 0
        case accepted = 1
        case inRoute = 2
        case started = 3
        case completed = 4
        case reviewed = 5
        case canceledByProvider = 6
        case canceledByCustomer = 7
        
        var description: String {
            switch self {
            case .pending:
                return "Pending Task"
            case .accepted:
                return "Task Is Accepted"
            case .inRoute:
                return "Provider In Route"
            case .started:
                return "Task In Progress"
            case .completed:
                return "Task Is Completed"
            case .reviewed:
                return "Task Is Reviewed"
            case .canceledByProvider:
                return "Task Is Canceled"
            case .canceledByCustomer:
                return "Task is canceled by customer"
            }
        }
    }
    
    enum GrassLength: String {
        case maintained = "Maintained"
        case average = "Average"
        case overgrown = "Overgrown"
    }
    
    enum Frequency: String {
        case oneTime = "One Time"
        case weekly = "Weekly"
        case biweekly = "Bi-Weekly"
    }
    
    enum LawnSize: String {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
    }
    
    enum When: String {
        case now = "now"
        case asap = "asap"
        case schedule = "schedule"
    }
}
