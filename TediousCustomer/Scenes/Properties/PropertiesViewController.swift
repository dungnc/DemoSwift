//
//  PropertiesViewController.swift
//  TediousCustomer
//
//  Created by Artem Kirichek on 4/25/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit

class PropertiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    
    fileprivate lazy var myTasksViewModel: TasksViewModel = TasksViewModel(mode: .MyTasks)
    fileprivate lazy var availableTasksViewModel: TasksViewModel = TasksViewModel(mode: .AvailableTasks)
    fileprivate var taskDetailsViewController: TaskDetailsViewController?
    
    fileprivate var viewModel: TasksViewModel {
        return segmentedControl.selectedSegmentIndex == 0 ? availableTasksViewModel : myTasksViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupTableView() {
        let cellNib = UINib(nibName:"TaskTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "TaskTableViewCellIdentifier")
    }
    
    fileprivate func setupTasks() {
        availableTasksViewModel
            .rx_taskViewModels
            .asObservable()
            .subscribe(onNext: { [weak self] (sections) in
                guard let `self` = self else { return }
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: rx.disposeBag)
        myTasksViewModel
            .rx_taskViewModels
            .asObservable()
            .subscribe(onNext: { [weak self] (sections) in
                guard let `self` = self else { return }
                if self.segmentedControl.selectedSegmentIndex == 1 {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard Provider.current != nil else { return 0 }
        return viewModel.rx_taskViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCellIdentifier", for: indexPath) as! TaskTableViewCell
        cell.viewModel = viewModel.rx_taskViewModels.value[indexPath.row]
        cell.delegate = self
        return cell
    }
}
