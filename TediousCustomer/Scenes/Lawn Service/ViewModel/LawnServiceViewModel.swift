//
//  LawnServiceViewModel.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 5/16/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation
import SVProgressHUD

class LawnServiceViewModel: NSObject {
    
    var rx_task: Variable<Task>
    
    init(address: String, location: CLLocation, lawnSize: Task.LawnSize?) {
        let task = Task(live: Customer.current!.live, customerId: Customer.current!.id, address: address, location: location, lawnSize: lawnSize)
        rx_task = Variable(task)
        super.init()
        setupPricing()
    }
    
    deinit {
        print("LawnServiceViewModel deinit")
    }
    
    func setupPricing() {
        PricingDataProvider.shared.rx_pricingLawnService
            .asObservable()
            .subscribe(onNext: { [weak self] (pricing) in
                guard let `self` = self else { return }
                self.rx_task.value = self.rx_task.value
            }).disposed(by: rx.disposeBag)
    }
    
    var confirmButtonTitle: NSAttributedString {
        var priceString: String = ""
        if let pricing = PricingDataProvider.shared.rx_pricingLawnService.value {
            if rx_task.value.isRecurring {
                priceString = "$\(pricing.firstTimePriceForRecurring(task: rx_task.value))"
            } else {
                priceString = "$\(pricing.price(forTask: rx_task.value))"
            }
        }
        var title: String
        if rx_task.value.frequency ?? .oneTime == .oneTime {
            title = "CONFIRM \(priceString)"
        } else {
            title = "CONFIRM & PAY \(priceString)"
        }
        let regularAttributes = [NSAttributedStringKey.font: UIFont(name: K.Font.Regular, size: 16)!,
                                 NSAttributedStringKey.foregroundColor: UIColor.white]
        let attrString = NSMutableAttributedString(string: title, attributes: regularAttributes)
        let subAttributes = [NSAttributedStringKey.font: UIFont(name: K.Font.Bold, size: 16)!]
        attrString.addAttributes(subAttributes,
                                 range: (title as NSString).range(of: priceString))
        return attrString
    }
    
    var reoccurServiceHint: String {
        guard rx_task.value.isRecurring else {
            return ""
        }
        let pricing = PricingDataProvider.shared.rx_pricingLawnService.value
        if let price = pricing?.price(forTask: rx_task.value) {
            return "*Reoccurring services will be billed at $\(price)*"
        } else {
            return ""
        }
    }
    
    open func submitTask(_ completion: @escaping (_ task: TaskDetailsViewModel?, _ error: Error?) -> ()) {
        var task = rx_task.value
        guard let receipt = Receipt(task: task, discountForFirstRecurringTask: task.isRecurring) else {
            completion(nil, nil)
            return
        }
        task.receipt = receipt
        PaymentsManager.charge(for: task, customer: Customer.current!, capture: false) { [weak self] (task, error) in
            if var task = task {
                if task.isRecurring {
                    SubscriptionsDataProvider.shared.saveSubscription(Subscription(task: task),
                                                                      customerId: Customer.current!.id,
                                                                      completion: { [weak self] (subscription, error) in
                        task.subscriptionId = subscription?.id
                        self?.createTask(task, completion)
                    })
                } else {
                    self?.createTask(task, completion)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func createTask(_ task: Task, _ completion: @escaping (_ task: TaskDetailsViewModel?, _ error: Error?) -> ()) {
        TasksDataProvider.shared.createTask(task, customerId: Customer.current!.id)
            .subscribe(onSuccess: { [weak self] (task) in
                print("\(#function) task: \(task)")
                self?.rx_task.value = task
                PushNotificationManager.notifyProvidersAboutAvailableTask(task)
                completion(TaskDetailsViewModel(task: task), nil)
            }, onError: { (error) in
                print("\(#function) error \(error)")
                completion(nil, error)
            }).disposed(by: self.rx.disposeBag)
    }
    
    var lawnSize: String {
        if let lawnSize = rx_task.value.lawnSize {

            return "\(lawnSize.rawValue) Size"
        } else {
            return "--------"
        }
    }
    
    var grassLength: String {
        if let grassLength = rx_task.value.grassLength {
            return "\(grassLength.rawValue)"
        } else {
            return "--------"
        }
    }
    
    var frequency: String {
        if let frequency = rx_task.value.frequency {
            return "\(frequency.rawValue)"
        } else {
            return "--------"
        }
    }
    
    var next: String {
        var next: String?
        if let frequency = rx_task.value.frequency {
            let date = rx_task.value.scheduleAt ?? Date()
            if frequency == .weekly {
                let nextDate = Date(timeIntervalSince1970: date.timeIntervalSince1970 + 3600 * 24 * 7)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                next = "Next \(dateFormatter.string(from: nextDate))"
            } else if frequency == .biweekly {
                let nextDate = Date(timeIntervalSince1970: date.timeIntervalSince1970 + 3600 * 24 * 14)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                next = dateFormatter.string(from: nextDate)
            }
        }
        return next ?? "--------"
    }
    
    var confirmButtonEnabled: Bool {
        if rx_task.value.grassLength != nil &&
            rx_task.value.when != nil &&
            rx_task.value.frequency != nil &&
            rx_task.value.lawnSize != nil &&
            (Customer.current!.cards?.count ?? 0) > 0 {
            return true
        } else {
            return false
        }
    }
}
