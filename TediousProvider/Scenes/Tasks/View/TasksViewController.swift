//
//  TasksViewController.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 4/11/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import NSObject_Rx
import Firebase

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProviderTaskTableViewCellDelegate, TaskDetailsViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    
    fileprivate var myTasksViewModel: TasksViewModel {
        return MainTabBarController.shared.myTasksViewModel
    }
    fileprivate var availableTasksViewModel: TasksViewModel {
        return MainTabBarController.shared.availableTasksViewModel
    }
    fileprivate var taskDetailsViewController: TaskDetailsViewController?
    
    fileprivate var viewModel: TasksViewModel {
        return segmentedControl.selectedSegmentIndex == 1 ? myTasksViewModel : availableTasksViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let taskDetailsViewController = destination as? TaskDetailsViewController {
            taskDetailsViewController.viewModel = sender as! TaskDetailsViewModel
            taskDetailsViewController.delegate = self
            self.taskDetailsViewController = taskDetailsViewController
        }
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
        return viewModel.rx_taskViewModels.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCellIdentifier", for: indexPath) as! TaskTableViewCell
        cell.viewModel = viewModel.rx_taskViewModels.value![indexPath.row]
        cell.providerDelegate = self
        return cell
    }
    
    // MARK: - TaskTableViewCellDelegate
    
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, didAcceptTask task: TaskDetailsViewModel) {
        viewModel.acceptTask(task)
    }
    
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, didNavigateToTask task: TaskDetailsViewModel) {
        func goToTaskDetails(task: TaskDetailsViewModel) {
            if let taskDetailsViewController = taskDetailsViewController {
                taskDetailsViewController.viewModel = task
                navigationController?.pushViewController(taskDetailsViewController, animated: true)
            } else {
                performSegue(withIdentifier: K.Storyboard.SegueIdentifier.TaskDetails, sender: task)
            }
        }
        if task.rx_task.value.status == .accepted {
            viewModel.navigateToLocation(taskDetailsViewModel: task, completion: { (task, error) in
                if let task = task {
                    goToTaskDetails(task: task)
                }
            })
        } else {
            goToTaskDetails(task: task)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func customSegmentedControlValueChanged(_ sender: CustomSegmentedControl) {
        self.tableView.reloadData()
    }
    
    // MARK: - ProviderTaskTableViewCellDelegate
    
    func taskDetailsViewController(_ taskDetailsViewController: TaskDetailsViewController, didCompleteTask taskDetailsViewMode: TaskDetailsViewModel) {
        navigationController?.popViewController(animated: true)
        segmentedControl.selectButton(atIndex: 0)
    }
}
