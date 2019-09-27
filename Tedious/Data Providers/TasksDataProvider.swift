//
//  TasksDataProvider.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/12/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore

class TasksDataProvider: NSObject {
    
    static var shared: TasksDataProvider = TasksDataProvider()
    
    fileprivate let db: Firestore
    
    override init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // MARK: - Public Methods
    
    open func subscribeOnMyTasks(_ provider: Provider) -> Observable<[Task]> {
        let query = db.collection(K.Firestore.Collection.Providers.Name).document(provider.id)
            .collection(K.Firestore.Collection.Tasks.Name)
            .whereField(K.Firestore.Collection.Tasks.Field.Status, isLessThanOrEqualTo: Task.Status.started.rawValue)
        return subscribeOnTasks(query: query)
    }
    
    open func subscribeOnAvailableTasks(_ provider: Provider) -> Observable<[Task]> {
        let collectionRef = db.collection(K.Firestore.Collection.Tasks.Available.Name)
        return subscribeOnTasks(collectionRef: collectionRef, descending: false)
    }
    
    open func subscribeOnActiveTasks(_ customer: Customer) -> Observable<[Task]> {
        let query = db.collection(K.Firestore.Collection.Customers.Name).document(customer.id)
            .collection(K.Firestore.Collection.Tasks.Name)
            .whereField(K.Firestore.Collection.Tasks.Field.Status, isLessThanOrEqualTo: Task.Status.started.rawValue)
        return subscribeOnTasks(query: query)
    }
    
    open func subscribeOnCompleteTasks(_ customer: Customer) -> Observable<[Task]> {
        let query = db.collection(K.Firestore.Collection.Customers.Name).document(customer.id)
            .collection(K.Firestore.Collection.Tasks.Name)
            .whereField(K.Firestore.Collection.Tasks.Field.Status, isGreaterThanOrEqualTo: Task.Status.completed.rawValue)
        return subscribeOnTasks(query: query)
    }
    
    open func subscribeOnMyTasks(_ provider: Provider, startDate: Date, endDate: Date) -> Observable<[Task]> {
        let query = db.collection(K.Firestore.Collection.Providers.Name).document(provider.id)
            .collection(K.Firestore.Collection.Tasks.Name)
            .whereField(K.Firestore.Collection.Tasks.Field.StartedAt, isGreaterThanOrEqualTo: startDate)
            .whereField(K.Firestore.Collection.Tasks.Field.StartedAt, isLessThanOrEqualTo: endDate)
        return subscribeOnTasks(query: query)
    }

    open func subscribeOnTask(_ task: Task, byCustomer customer: Customer) -> Observable<Task?> {
        return db.collection(K.Firestore.Collection.Customers.Name).document(customer.id)
                .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
                .rx.listen()
                .map { (document) -> Task? in
                    if document.exists {
                        return Task(dictionary: document.data()!)
                    } else {
                        return nil
                    }
            }
    }
    
    open func createTask(_ task: Task, customerId: String) -> Single<Task> {
        let collectionRef = db.collection(K.Firestore.Collection.Tasks.Available.Name).document()
        var task = task
        task.id = collectionRef.documentID
        //Create task for customer
        db.collection(K.Firestore.Collection.Customers.Name).document(customerId)
            .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
            .setData(task.toAny)
        //Create task for providers
        return collectionRef
                .rx.set(task.toAny)
                .map({ Void -> Task in
                    return task
                })
    }
    
    open func acceptTask(_ task: Task, byProvider provider: Provider) -> Single<Task> {
        let taskReference = db.collection(K.Firestore.Collection.Tasks.Available.Name).document(task.id)
        var acceptedTask = task
        acceptedTask.status = .accepted
        acceptedTask.providerId = provider.id
        return db.rx.runTransaction { [weak self] (transaction, errorPointer) -> Any? in
            print("acceptTask: runTransaction")
                guard let `self` = self else { return nil }
                do {
                    try _ = transaction.getDocument(taskReference)
                } catch {
                    let error = NSError(
                        domain: "",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "This task has already been accepted by another provider."
                        ]
                    )
                    errorPointer?.pointee = error
                    print("This task has already been accepted by another provider.")
                    return nil
                }
                let newProviderTaskRef = self.db.collection(K.Firestore.Collection.Providers.Name).document(provider.id)
                    .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
                let newCustomerTaskRef = self.db.collection(K.Firestore.Collection.Customers.Name).document(task.customerId)
                .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
                transaction.setData(acceptedTask.toAny, forDocument: newProviderTaskRef)
                transaction.setData(acceptedTask.toAny, forDocument: newCustomerTaskRef)
                transaction.deleteDocument(taskReference)
                return nil
            }
            .map({ (_) -> Task in
                return acceptedTask
            })
    }
    
    open func save(task: Task, for providerId: String, completion: @escaping (_ task: Task?, _ error: Error?) -> ()) {
        let batch = db.batch()
        //Updated task for customer
        let taskForCustomerRef = db.collection(K.Firestore.Collection.Customers.Name).document(task.customerId)
                .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
        batch.setData(task.toAny, forDocument: taskForCustomerRef)
        //Updated task for provider
        let taskForProviderRef = db.collection(K.Firestore.Collection.Providers.Name).document(providerId)
            .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
        batch.setData(task.toAny, forDocument: taskForProviderRef)
        batch.commit(completion: { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(task, nil)
            }
        })
    }
    
    open func deleteTask(task: Task, byCustomer customer: Customer) -> Single<Task> {
        if let providerId = task.providerId {
            db.collection(K.Firestore.Collection.Providers.Name).document(providerId)
                .collection(K.Firestore.Collection.Tasks.Name).document(task.id).delete()
        } else {
            db.collection(K.Firestore.Collection.Tasks.Available.Name).document(task.id).delete()
        }
        return db.collection(K.Firestore.Collection.Customers.Name).document(customer.id)
                .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
                .rx.delete()
                .map { () -> Task in
                    var deletedTask = task
                    deletedTask.status = .canceledByCustomer
                    return deletedTask
                }
    }
    
    open func cancelTask(_ task: Task, completion: @escaping (_ task: Task?, _ error: Error?) -> ()) {
        //Step 1: Update task status for customer
        var cancelTask = task
        cancelTask.status = .pending
        cancelTask.providerId = nil
        
        let batch = db.batch()
        let taskForCustomerRef = db.collection(K.Firestore.Collection.Customers.Name).document(task.customerId)
            .collection(K.Firestore.Collection.Tasks.Name).document(task.id)
        batch.setData(cancelTask.toAny, forDocument: taskForCustomerRef)
        
        //Step 2: Move the task to available tasks
        let availableTasksRef = self.db.collection(K.Firestore.Collection.Tasks.Available.Name).document(task.id)
        batch.setData(cancelTask.toAny, forDocument: availableTasksRef)
        
        //Step 3: Commit the change
        batch.commit(completion: { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(task, nil)
            }
        })
    }
}

// MARK: - Private Methods

extension TasksDataProvider {
    fileprivate func subscribeOnTasks(collectionRef: CollectionReference, descending: Bool) -> Observable<[Task]> {
        let query = collectionRef.order(by: K.Firestore.Collection.Tasks.Field.CreatedAt, descending: descending)
        return subscribeOnTasks(query: query)
    }
    
    fileprivate func subscribeOnTasks(query: Query) -> Observable<[Task]> {
        return query.rx.listen()
            .map({ querySnapshot -> [Task] in
//                for document in querySnapshot.documents {
//                    print("querySnapshot \(document.documentID) => \(document.data())")
//                }
//                for changes in querySnapshot.documentChanges {
//                    print("documentChanges \(changes.type.rawValue) => \(changes.document.data())")
//                }
                return querySnapshot.documents.map { Task(dictionary: $0.data()) }
            })
    }
}
