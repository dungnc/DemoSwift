//
//  TaskTableViewCell.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/11/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import AlamofireImage

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var taskTypeLabel: UILabel!
    @IBOutlet weak var grassLengthLabel: UILabel!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    weak var providerDelegate: ProviderTaskTableViewCellDelegate?
    weak var customerDelegate: CustomerTaskTableViewCellDelegate?
    
    weak var viewModel: TaskDetailsViewModel! {
        didSet {
            let task = viewModel.rx_task.value
            addressLabel.text = task.address
            if Provider.current != nil {
                if viewModel.rx_task.value.status == .pending {
                    processButton.setTitle("Add to My Task", for: .normal)
                } else {
                    processButton.setTitle("Navigate To Location", for: .normal)
                }
            } else if Customer.current != nil {
                switch viewModel.rx_task.value.status {
                case .pending:
                    fallthrough
                case .accepted:
                    fallthrough
                case .inRoute:
                    fallthrough
                case .started:
                    processButton.setTitle("Cancel", for: .normal)
                case .reviewed:
                    fallthrough
                case .completed:
                    fallthrough
                case .canceledByProvider:
                    fallthrough
                case .canceledByCustomer:
                    processButton.setTitle("View Details", for: .normal)
                }
            }
            if photoImageView != nil {
                setupPhoto()
            }
            if let grassLength = task.grassLength {
                grassLengthLabel?.text = grassLength.rawValue
            }
            if let lawnSize = task.lawnSize {
                taskTypeLabel?.text = "\(lawnSize.rawValue) Lawn"
            }
            adjustDateView()
            adjustCompleteTask()
            setupReview()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        taskTypeLabel?.layer.cornerRadius = taskTypeLabel.frame.height / 2
        grassLengthLabel?.layer.cornerRadius = grassLengthLabel.frame.height / 2
        
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        containerView.layer.shadowOpacity = 0.42
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 2
        photoImageView?.layer.cornerRadius = photoImageView.frame.width / 2
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupPhoto() {
        if K.App.Target == .Customer {
            photoImageView.image = #imageLiteral(resourceName: "provider_default")
        } else {
            photoImageView.image = #imageLiteral(resourceName: "customer_default")
        }
        viewModel
            .rx_photoUrl
            .asObservable()
            .subscribe(onNext: { [weak self] (photoUrl) in
                if let photoUrl = photoUrl {
                    self?.photoImageView.af_setImage(withURL: photoUrl)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    fileprivate func setupReview() {
        guard let ratingView = ratingView else {
            return
        }
        ratingView.isHidden = true
        viewModel
            .rx_review
            .asObservable()
            .subscribe(onNext: { (review) in
                if let review = review {
                    ratingView.isHidden = false
                    ratingView.rating = Double(review.rating)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    fileprivate func adjustCompleteTask() {
        let task = viewModel.rx_task.value
        durationLabel?.text = Utils.durationToString(task.duration ?? 0)
        var priceString = "$"
        priceString += task.receipt.subTotal.toString(centsRequired: false)
        if let tip = task.receipt.tip {
            priceString += " + $\(tip.toString(centsRequired: false)) tip"
        }
        self.priceLabel?.text = priceString
    }
    
    fileprivate func adjustDateView() {
        let task = viewModel.rx_task.value
        if task.when! == .now && [Task.Status.pending, Task.Status.accepted, Task.Status.inRoute, Task.Status.started].contains(task.status) {
            dateImageView.image = #imageLiteral(resourceName: "now")
            dateLabel.text = "NOW"
            dateLabel.font = UIFont(name: K.Font.SemiBold, size: 12)!
            dateLabel.textColor = UIColor.white
        } else if task.when! == .asap && [Task.Status.pending, Task.Status.accepted, Task.Status.inRoute, Task.Status.started].contains(task.status) {
            dateImageView.image = #imageLiteral(resourceName: "date")
            dateLabel.text = "ASAP"
            dateLabel.font = UIFont(name: K.Font.SemiBold, size: 12)!
            dateLabel.textColor = UIColor(hex: 0x606060)
        } else {
            dateImageView.image = #imageLiteral(resourceName: "date")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            var dateString = ""
            if Calendar.current.isDateInToday(task.scheduleAt) {
                dateString = "Today"
            } else {
                dateString = dateFormatter.string(from: task.scheduleAt)
            }
            let header = "Lawn Service - \(dateString)"
            let regularAttributes = [NSAttributedStringKey.font: UIFont(name: K.Font.Regular, size: 12)!, NSAttributedStringKey.foregroundColor: UIColor(hex: 0x606060)]
            let attrString = NSMutableAttributedString(string: header, attributes: regularAttributes)
            let subAttributes = [NSAttributedStringKey.font: UIFont(name: K.Font.SemiBold, size: 12)!]
            attrString.addAttributes(subAttributes,
                                     range: (header as NSString).range(of: dateString))
            dateLabel.attributedText = attrString
        }
    }
    
    // MARK: - Actions
    
    @IBAction func processButtonClicked(_ sender: UIButton) {
        if Provider.current != nil {
            if viewModel.rx_task.value.status == .pending {
                providerDelegate?.taskTableViewCell(self, didAcceptTask: viewModel)
            } else {
                providerDelegate?.taskTableViewCell(self, didNavigateToTask: viewModel)
            }
        } else if Customer.current != nil {
            switch viewModel.rx_task.value.status {
            case .pending:
                fallthrough
            case .accepted:
                fallthrough
            case .inRoute:
                fallthrough
            case .started:
                customerDelegate?.taskTableViewCell(self, didCancelTask: viewModel)
            case .reviewed:
                fallthrough
            case .completed:
                fallthrough
            case .canceledByProvider:
                fallthrough
            case .canceledByCustomer:
                customerDelegate?.taskTableViewCell(self, didViewDetailsTask: viewModel)
            }
        }
    }
}

protocol ProviderTaskTableViewCellDelegate: NSObjectProtocol {
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, didAcceptTask task: TaskDetailsViewModel)
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, didNavigateToTask task: TaskDetailsViewModel)
}

protocol CustomerTaskTableViewCellDelegate: NSObjectProtocol {
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, didCancelTask task: TaskDetailsViewModel)
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, didViewDetailsTask task: TaskDetailsViewModel)
}
