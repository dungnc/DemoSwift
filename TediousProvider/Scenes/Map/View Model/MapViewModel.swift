//
//  MapViewModel.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 5/3/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD
import CoreLocation
import NSObject_Rx

class MapViewModel: NSObject {
    
    let rx_currentLocation: Variable<CLLocation?> = Variable(nil)
    var rx_taskViewModels: Variable<[TaskDetailsViewModel]?> = Variable(nil)
    var availableTasksViewModel: TasksViewModel! {
        return MainTabBarController.shared.availableTasksViewModel
    }
    
    override init() {
        super.init()
        updateLocation()
        subscribeOnTasks()
    }
    
    deinit {
        print("MapViewModel deinit")
    }
    
    func updateLocation() {
        LocationHelper.shared.rx_currentLocation
            .asObservable()
            .filter({ $0 != nil })
            .map({ $0! })
            .subscribe(onNext: { [weak self] (location) in
                if self?.rx_currentLocation.value == nil {
                    self?.rx_currentLocation.value = location
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func subscribeOnTasks() {
        availableTasksViewModel.rx_taskViewModels.asObservable()
            .subscribe(onNext: {  [weak self] (tasks) in
                if let tasks = tasks {
                    self?.rx_taskViewModels.value = tasks
                }
        }).disposed(by: rx.disposeBag)
    }
}


