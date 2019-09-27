//
//  EarningsViewModel.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 4/27/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD

class EarningsViewModel: NSObject {
    
    var allTasksViewModels: [Date: [TaskDetailsViewModel]] = [:]
    var rx_dates: Variable<[Date]> = Variable([])
    var weeklyIntervalDates: [(startDate: Date, endDate: Date)]!
    var selectedDates: (startDate: Date, endDate: Date)!
    var weeklyEarnings: String = ""
    var totalEarnings: String = ""
    var taskCount: String = ""
    var totalDuration: String = ""
    var totalTips: String = ""
    
    init(selectedDates: (startDate: Date, endDate: Date)? = nil) {
        super.init()
        createWeeklyIntervalDates()
        if let selectedDates = selectedDates {
            self.selectedDates = selectedDates
        } else {
            self.selectedDates = weeklyIntervalDates[0]
        }
        subscribeOnTasks()
    }
    
    deinit {
        print("EarningsViewModel deinit")
    }
    
    func subscribeOnTasks() {
        let (startDate, endDate) = selectedDates
        SVProgressHUD.show()
        TasksDataProvider.shared.subscribeOnMyTasks(Provider.current!, startDate: startDate, endDate: endDate)
            .subscribe(onNext: { [weak self] (tasks) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            let completedTasks = tasks.filter({ $0.status == .completed || $0.status == .reviewed })
            print("\(#function) task: \(tasks)")
            self.sortTasks(completedTasks)
        }, onError: { (error) in
            print("\(#function) error:  \(error)")
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }).disposed(by: rx.disposeBag)
    }
    
    func sortTasks(_ tasks: [Task]) {
        var allTasksViewModels: [Date: [TaskDetailsViewModel]] = [:]
        var dates: [Date] = []
        for task in tasks {
            let date = task.startedAt ?? Date()
            let secondsInDay = 60*60*24
            let timeInterval = Int(date.timeIntervalSince1970 / Double(secondsInDay)) * secondsInDay
            let keyDate = Date(timeIntervalSince1970: Double(timeInterval))
            let taskDetailsViewModel = TaskDetailsViewModel(task: task)
            if var tasksByDate = allTasksViewModels[keyDate] {
                tasksByDate.append(taskDetailsViewModel)
                allTasksViewModels[keyDate] = tasksByDate
            } else {
                allTasksViewModels[keyDate] = [taskDetailsViewModel]
                dates.append(keyDate)
            }
        }
        self.allTasksViewModels = allTasksViewModels
        self.calculateEarnings()
        self.rx_dates.value = dates.sorted(by: { $0 > $1 })
    }
    
    func createWeeklyIntervalDates() {
        weeklyIntervalDates = []
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        for i in 0..<24 {
            var dateComponents = calendar.dateComponents([.year], from: Date())
            dateComponents.calendar = calendar
            dateComponents.hour = 23
            dateComponents.minute = 59
            dateComponents.second = 59
            dateComponents.weekOfYear = currentWeek - i
            dateComponents.weekday = 1
            let stardDate = dateComponents.date!
            dateComponents.weekday = 7
            let endDate = dateComponents.date!
            weeklyIntervalDates.append((stardDate, endDate))
        }
    }
    
    func calculateEarnings() {
        var weeklyEarnings: Price = 0
        var totalEarnings: Price = 0
        var taskCount = 0
        var totalDuration: TimeInterval = 0
        var totalTips: Price = 0
        for (_, tasks) in allTasksViewModels {
            for task in tasks {
                weeklyEarnings += task.rx_task.value.receipt.subTotal
                totalEarnings += task.rx_task.value.receipt.subTotal
                taskCount += 1
                let duration = task.rx_task.value.duration ?? 0
                totalDuration += ceil(duration / 60) * 60
                totalTips += task.rx_task.value.receipt.tip ?? 0
            }
        }
        self.weeklyEarnings = "$\(weeklyEarnings)"
        self.totalEarnings = "$\(totalEarnings)"
        self.taskCount = "\(taskCount)"
        self.totalDuration = Utils.durationToString(totalDuration).lowercased()
        self.totalTips = "$\(totalTips)"
    }
    
    enum Mode: CustomStringConvertible {
        case WeeklyView
        case DailyView
        
        var description: String {
            switch self {
            case .WeeklyView:
                return "WeeklyView"
            case .DailyView:
                return "DailyView"
            }
        }
    }
}
