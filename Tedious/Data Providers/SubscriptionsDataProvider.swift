//
//  SubscriptionsDataProvider.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 5/24/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore

class SubscriptionsDataProvider: NSObject {
    
    static var shared: SubscriptionsDataProvider = SubscriptionsDataProvider()
    fileprivate let db: Firestore
    
    override init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    open func subscribeOnSubscriptions(_ customer: Customer) -> Observable<[Subscription]> {
        let query = db.collection(K.Firestore.Collection.Customers.Name).document(customer.id)
            .collection(K.Firestore.Collection.Subscriptions.Name)
        return query.rx.listen()
            .map({ querySnapshot -> [Subscription] in
                return querySnapshot.documents.map { $0.data() }.map({ Subscription(dictionary: $0) })
            })
    }
    
    open func loadSubscription(byId subscriptionId: String, customerId: String, completion: @escaping (_ subscription: Subscription?, _ error: Error?) -> ()) {
        let docRef = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
                    .collection(K.Firestore.Collection.Subscriptions.Name).document(subscriptionId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let subscription = Subscription(dictionary: document.data()!)
                completion(subscription, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    open func loadSubscriptions(byCustomerId customerId: String, completion: @escaping (_ subscriptions: [Subscription]?, _ error: Error?) -> ()) {
        let ref = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
            .collection(K.Firestore.Collection.Subscriptions.Name)
        ref.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                let subscriptions = querySnapshot.documents.map { Subscription(dictionary: $0.data()) }
                completion(subscriptions, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    open func saveSubscription(_ subscription: Subscription, customerId: String, completion: @escaping (_ subscription: Subscription?, _ error: Error?) -> ()) {
        var subscription = subscription
        
        //Subscription itself
        let subscriptionRef: DocumentReference
        if let id = subscription.id {
            subscriptionRef = db.collection(K.Firestore.Collection.Subscriptions.Name).document(id)
        } else {
            subscriptionRef = db.collection(K.Firestore.Collection.Subscriptions.Name).document()
            subscription.id = subscriptionRef.documentID
        }
        
        //Customer's Subscription
        let customerSubscriptionRef = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
                                    .collection(K.Firestore.Collection.Subscriptions.Name).document(subscription.id)
        let batch = db.batch()
        batch.setData(subscription.toAny, forDocument: subscriptionRef)
        batch.setData(subscription.toAny, forDocument: customerSubscriptionRef)
        batch.commit { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(subscription, nil)
            }
        }
    }
    
    open func removeSubscription(atId subscriptionId: String, customerId: String, completion: @escaping (_ error: Error?) -> ()) {
        let batch = db.batch()
        //Remove subscription itself
        let subscriptionRef = db.collection(K.Firestore.Collection.Subscriptions.Name).document(subscriptionId)
        batch.deleteDocument(subscriptionRef)
        //Remove subscription from customer table
        let subscriptionCustomerRef = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
            .collection(K.Firestore.Collection.Subscriptions.Name).document(subscriptionId)
        batch.deleteDocument(subscriptionCustomerRef)
        //Remove pending tasks from Customer's table
        let customerTasksSignal = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
            .collection(K.Firestore.Collection.Tasks.Name)
            .whereField(K.Firestore.Collection.Tasks.Field.Status, isEqualTo: Task.Status.pending.rawValue)
            .whereField(K.Firestore.Collection.Tasks.Field.SubscriptionId, isEqualTo: subscriptionId)
            .rx.getDocuments().map({ $0.documents }).asObservable()
        //Remove pending tasks from Available Tasks table
        let availableTasksSignal = db.collection(K.Firestore.Collection.Tasks.Available.Name)
            .whereField(K.Firestore.Collection.Tasks.Field.CustomerId, isEqualTo: customerId)
            .whereField(K.Firestore.Collection.Tasks.Field.SubscriptionId, isEqualTo: subscriptionId)
            .rx.getDocuments().map({ $0.documents }).asObservable()
        Observable.combineLatest(customerTasksSignal, availableTasksSignal).subscribe(onNext: { (d1, d2) in
            let documents = d1 + d2
            documents.forEach({ batch.deleteDocument($0.reference) })
            batch.commit(completion: { (error) in
                completion(error)
            })
            completion(nil)
        }, onError: { (error) in
            completion(error)
        }).disposed(by: rx.disposeBag)
    }
    
    open func syncSubscriptions(forCustomerId customerId: String, completion: @escaping (_ error: Error?) -> ()) {
        let batch = db.batch()

        func addSubscriptionToBatch(_ subscription_: Subscription) {
            var subscription = subscription_
            let availableTaskRef = db.collection(K.Firestore.Collection.Tasks.Available.Name).document()
            var task = Task.nextTask(fromSubscription: subscription)
            subscription.nextTaskScheduleAt = task.scheduleAt
            task.id = availableTaskRef.documentID

            let customerTaskRef = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
                .collection(K.Firestore.Collection.Tasks.Name).document(task.id)

            let subscriptionRef = db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
                .collection(K.Firestore.Collection.Subscriptions.Name).document(subscription.id)

            batch.setData(task.toAny, forDocument: customerTaskRef)
            batch.setData(task.toAny, forDocument: availableTaskRef)
            batch.setData(subscription.toAny, forDocument: subscriptionRef)
        }

        loadSubscriptions(byCustomerId: customerId) { (subscriptions, error) in
            if let subscriptions = subscriptions {
                subscriptions.filter({ $0.nextTaskScheduleAt == nil }).forEach({ addSubscriptionToBatch($0) })
                batch.commit(completion: { (error) in
                    completion(error)
                })
            } else {
                completion(error)
            }
        }
    }
}
