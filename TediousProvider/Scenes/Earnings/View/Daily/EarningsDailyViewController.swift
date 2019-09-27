//
//  EarningsDailyViewController.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 4/28/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit

class EarningsDailyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weeklyEarningsLabel: UILabel!
    @IBOutlet weak var taskCountLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var totalEarningsLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!

    open var viewModel: EarningsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupTasks()
        self.reloadData()
        
        tableView.layer.cornerRadius = 5
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor(hex: 0xE3E3E3).cgColor
        navigationItem.hidesBackButton = true
    }

    deinit {
        tableView?.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tableView.layer.removeAllAnimations()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupTableView() {
        var nib = UINib(nibName:"EarningsDailyTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "EarningsDailyTableViewCellIdentifier")
        tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        nib = UINib(nibName:"EarningsDailyTableViewHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "EarningsDailyTableViewHeaderIdentifier")
    }
    
    fileprivate func setupTasks() {
        viewModel
            .rx_dates
            .asObservable()
            .subscribe(onNext: { [weak self] (sections) in
                guard let `self` = self else { return }
                self.tableView.reloadData()
                self.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    fileprivate func reloadData() {
        weeklyEarningsLabel.text = viewModel.weeklyEarnings
        taskCountLabel.text = viewModel.taskCount
        totalDurationLabel.text = viewModel.totalDuration
        totalEarningsLabel.text = viewModel.totalEarnings
        totalTipsLabel.text = viewModel.totalTips
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.rx_dates.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = viewModel.rx_dates.value[section]
        let tasksViewModels = viewModel.allTasksViewModels[date]!
        return tasksViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EarningsDailyTableViewCellIdentifier", for: indexPath) as! EarningsDailyTableViewCell
        let dates = viewModel.rx_dates.value
        let date = dates[indexPath.section]
        let tasksViewModels = viewModel.allTasksViewModels[date]!
        let taskViewModel = tasksViewModels[indexPath.row]
        cell.viewModel = taskViewModel
        cell.separatorView.isHidden = (indexPath.section == dates.count - 1 && indexPath.row == tasksViewModels.count - 1)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 26 : 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EarningsDailyTableViewHeaderIdentifier") as! EarningsDailyTableViewHeader
        headerView.date = viewModel.rx_dates.value[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
