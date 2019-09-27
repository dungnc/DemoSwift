//
//  TasksViewModel.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 4/11/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD

class TasksViewModel: NSObject {
    
    var rx_taskViewModels: Variable<[TaskDetailsViewModel]?> = Variable(nil)
    var mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        super.init()
        subscribeOnTasks()
    }
    
    func subscribeOnTasks() {
        var observable: Observable<[Task]>
        switch mode {
        case .MyTasks:
            observable = TasksDataProvider.shared.subscribeOnMyTasks(Provider.current!)
        case .AvailableTasks:
            observable = TasksDataProvider.shared.subscribeOnAvailableTasks(Provider.current!)
        }
        observable.subscribe(onNext: { [weak self] (tasks) in
            guard let `self` = self else { return }
            //print("\(#function) mode: \(self.mode) tasks: \(tasks)")
            self.rx_taskViewModels.value = tasks
                .sorted(by: { $0.createdAt < $1.createdAt })
                .map({ TaskDetailsViewModel(task: $0) })
        }, onError: { (error) in
            print("\(#function) mode: \(self.mode) error:  \(error)")
            //SVProgressHUD.showError(withStatus: error.localizedDescription)
        }).disposed(by: rx.disposeBag)
    }
    
    func acceptTask(_ taskDetailsViewModel: TaskDetailsViewModel) {
        SVProgressHUD.show()
        TasksDataProvider.shared.acceptTask(taskDetailsViewModel.rx_task.value, byProvider: Provider.current!)
            .subscribe({ [weak self] (event) in
                guard let _ = self else { return }
                switch event {
                case let .success(task):
                    PushNotificationManager.sendTo(customerId: task.customerId, taskStatus: .accepted, byProvider: Provider.current!)
                    SVProgressHUD.showSuccess(withStatus: "Added to my tasks")
                    print("Transaction successfully committed! \(task)")
                    //self.rx_task.value = task
                case let .error(error):
                    print("Transaction failed: \(error)")
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func navigateToLocation(taskDetailsViewModel: TaskDetailsViewModel, completion: @escaping (_ task: TaskDetailsViewModel?, _ error: Error?) -> ()) {
        SVProgressHUD.show()
        ProvidersDataProvider.shared.sendCurrentLocation(nil, forProvider: Provider.current!)
        var task = taskDetailsViewModel.rx_task.value
        task.status = .inRoute
        TasksDataProvider.shared.save(task: task, for: Provider.current!.id) { (task, error) in
            if let task = task {
                SVProgressHUD.dismiss()
                LocationHelper.shared.startTrackingCurrentLocation()
                PushNotificationManager.sendTo(customerId: task.customerId, taskStatus: .inRoute, byProvider: Provider.current!)
                completion(TaskDetailsViewModel(task: task), nil)
            } else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    enum Mode: CustomStringConvertible {
        case MyTasks
        case AvailableTasks
        
        var description: String {
            switch self {
            case .MyTasks:
                return "MyTasks"
            case .AvailableTasks:
                return "AvailableTasks"
            }
        }
    }
}
