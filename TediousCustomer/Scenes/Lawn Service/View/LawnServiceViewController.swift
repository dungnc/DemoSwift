//
//  LawnServiceViewController.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/23/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import SVProgressHUD

class LawnServiceViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var oneTimeButton: UIButton!
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var biWeeklyButton: UIButton!
    @IBOutlet weak var up2HoursLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ccBrandImageView: UIImageView!
    @IBOutlet weak var ccNumberButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var grassLengthMaintainedButton: UIButton!
    @IBOutlet weak var grassLengthAverageButton: UIButton!
    @IBOutlet weak var grassLengthOvergrownButton: UIButton!
    @IBOutlet weak var whenNowButton: UIButton!
    @IBOutlet weak var whenAsapButton: UIButton!
    @IBOutlet weak var whenScheduleButton: UIButton!
    @IBOutlet weak var closeButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scheduleTextField: UITextField!
    @IBOutlet weak var lawnSizeSmallButton: UIButton!
    @IBOutlet weak var lawnSizeMediumButton: UIButton!
    @IBOutlet weak var lawnSizeLargeButton: UIButton!
    @IBOutlet weak var lawnSizeSmallLabel: UILabel!
    @IBOutlet weak var lawnSizeMediumLabel: UILabel!
    @IBOutlet weak var lawnSizeLargeLabel: UILabel!
    @IBOutlet weak var lawnSizeLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var grassLengthLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var grassLengthMaintainedLabel: UILabel!
    @IBOutlet weak var grassLengthAverageLabel: UILabel!
    @IBOutlet weak var grassLengthOvergrownLabel: UILabel!
    @IBOutlet weak var serviceWillReoccurLabel: UILabel!
    @IBOutlet weak var darkView: UIView!
    
    open weak var delegate: LawnServiceViewControllerDelegate?
    open var viewModel: LawnServiceViewModel!
    
    fileprivate var scheduleDatePicker: UIDatePicker!
    fileprivate var previousSwipingPoint: CGPoint?
    
    fileprivate var lawnSizeButtons: [UIButton] {
        return [lawnSizeSmallButton, lawnSizeMediumButton, lawnSizeLargeButton]
    }
    
    fileprivate var frequencyButtons: [UIButton] {
        return [oneTimeButton, weeklyButton, biWeeklyButton]
    }
    
    fileprivate var grassLengthButtons: [UIButton] {
        return [grassLengthMaintainedButton, grassLengthAverageButton, grassLengthOvergrownButton]
    }
    
    fileprivate var whenButtons: [UIButton] {
        return [whenNowButton, whenAsapButton, whenScheduleButton]
    }
    
    fileprivate var lawnSizeLabels: [UILabel] {
        return [lawnSizeSmallLabel, lawnSizeMediumLabel, lawnSizeLargeLabel]
    }
    
    fileprivate var grassLengthLabels: [UILabel] {
        return [grassLengthMaintainedLabel, grassLengthAverageLabel, grassLengthOvergrownLabel]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTaskDetails()
        adjustAddressContainerView()
        createScheduleDatePicker()
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(LawnServiceViewController.scrollViewPanGestureRecognized(_:)))
        
        if K.Device.IS_IPHONE_X {
            closeButtonTopConstraint.constant = 5
            scrollView.isScrollEnabled = false
        }
        
        if let lawnSize = viewModel.rx_task.value.lawnSize {
            switch lawnSize {
            case .small:
                lawnSizeSmallButton.isSelected = true
                adjustButtonAdditionalLabel(lawnSizeSmallLabel, selected: true)
            case .medium:
                lawnSizeMediumButton.isSelected = true
                adjustButtonAdditionalLabel(lawnSizeMediumLabel, selected: true)
            case .large:
                lawnSizeLargeButton.isSelected = true
                adjustButtonAdditionalLabel(lawnSizeLargeLabel, selected: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if let card = Customer.current!.cards?.first {
            ccNumberButton.setTitle("............\(card.last4)", for: .normal)
        } else {
            ccNumberButton.setTitle("Add Payment", for: .normal)
        }
        populateView()
    }
    
    // MARK: - Private Methods

    func adjustAddressContainerView() {
        addressContainerView.layer.cornerRadius = 10.0
        addressContainerView.layer.shadowColor = UIColor.black.cgColor
        addressContainerView.layer.shadowOpacity = 0.28
        addressContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        addressContainerView.layer.shadowRadius = 2
    }
    
    func populateView() {
        addressLabel.attributedText = NSAttributedString(string: viewModel.rx_task.value.address, attributes: addressLabel.attributedText!.attributes(at: 0, effectiveRange: nil))
        lawnSizeLabel.text = viewModel.lawnSize
        grassLengthLabel.text = viewModel.grassLength
        nextLabel.text = viewModel.next
        serviceWillReoccurLabel.text = viewModel.reoccurServiceHint
        confirmButton.setAttributedTitle(viewModel.confirmButtonTitle, for: .normal)
        confirmButton.isEnabled = viewModel.confirmButtonEnabled
    }
    
    func setupTaskDetails() {
        viewModel.rx_task
            .asObservable()
            .subscribe(onNext: { [weak self] (task) in
                self?.populateView()
            })
            .disposed(by: rx.disposeBag)
    }
    
    fileprivate func completeSwipeAnimation() {
        let progress: CGFloat = view.frame.origin.y / view.frame.height
        let isClosing: Bool = progress > 0.4
        let duration = TimeInterval(isClosing ? 1 - progress : progress) * 0.6
        UIView.animate(withDuration: duration, animations: {
            if isClosing {
                self.view.frame.origin.y = self.view.frame.height
            } else {
                self.view.frame.origin.y = 0
            }
        }) { (finished) in
            self.previousSwipingPoint = nil
            if isClosing {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    fileprivate func swipe(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view.superview)
        if let previousSwipingPoint = previousSwipingPoint {
            let deltaY = point.y - previousSwipingPoint.y
            if (view.frame.origin.y + deltaY) >= 0 {
                view.frame.origin.y += deltaY
            }
        }
        previousSwipingPoint = point
        switch sender.state {
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            completeSwipeAnimation()
        default:
            break
        }
    }
    
    @objc func scrollViewPanGestureRecognized(_ sender: UIPanGestureRecognizer) {
        if scrollView.contentOffset.y == 0 {
            swipe(sender: sender)
        } else {
            if previousSwipingPoint != nil {
                completeSwipeAnimation()
            }
        }
    }
    
    fileprivate func createScheduleDatePicker() {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.calendar = Calendar.current
        dateComponents.day! += 1
        scheduleDatePicker = UIDatePicker()
        scheduleDatePicker.datePickerMode = .date
        scheduleDatePicker.minimumDate = dateComponents.date
        dateComponents.hour = 23
        dateComponents.day! += 6
        scheduleDatePicker.maximumDate = dateComponents.date
        scheduleTextField.inputView = scheduleDatePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(LawnServiceViewController.doneDatePickerButtonClicked))
        Utils.adjustStyle(forDoneButton: doneButton)
        toolbar.setItems([doneButton], animated: true)
        scheduleTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneDatePickerButtonClicked(_ sender: UIBarButtonItem) {
        scheduleTextField.resignFirstResponder()
        darkView.isHidden = true
        viewModel.rx_task.value.scheduleAt = scheduleDatePicker.date
    }
    
    func adjustButtonAdditionalLabel(_ label: UILabel, selected: Bool) {
        if selected {
            label.textColor = UIColor.white
        } else {
            label.textColor = UIColor(hex: 0x606060)
        }
    }
    
    func selectBiWeeklyIfNeeded() {
        if viewModel.rx_task.value.frequency == nil {
            viewModel.rx_task.value.frequency = .biweekly
            biWeeklyButton.isSelected = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func grassLengthButtonClicked(_ sender: UIButton) {
        grassLengthButtons.forEach({ $0.isSelected = false })
        sender.isSelected = true
        grassLengthLabels.forEach({ self.adjustButtonAdditionalLabel($0, selected: false) })
        switch sender {
        case self.grassLengthMaintainedButton:
            viewModel.rx_task.value.grassLength = .maintained
            adjustButtonAdditionalLabel(grassLengthMaintainedLabel, selected: true)
        case self.grassLengthAverageButton:
            viewModel.rx_task.value.grassLength = .average
            adjustButtonAdditionalLabel(grassLengthAverageLabel, selected: true)
        case self.grassLengthOvergrownButton:
            viewModel.rx_task.value.grassLength = .overgrown
            adjustButtonAdditionalLabel(grassLengthOvergrownLabel, selected: true)
        default:
            break
        }
        selectBiWeeklyIfNeeded()
    }
    
    @IBAction func whenButtonClicked(_ sender: UIButton) {
        whenButtons.forEach { (button) in
            button.isSelected = false
            up2HoursLabel.textColor = UIColor.black
        }
        sender.isSelected = true
        
        switch sender {
        case self.whenNowButton:
            viewModel.rx_task.value.when = .now
            viewModel.rx_task.value.scheduleAt = Date()
            up2HoursLabel.textColor = UIColor.white
            UIView.animate(withDuration: 0.2) {
                self.up2HoursLabel.alpha = 1
            }
        case self.whenAsapButton:
            viewModel.rx_task.value.when = .asap
            viewModel.rx_task.value.scheduleAt = Date()
        case self.whenScheduleButton:
            viewModel.rx_task.value.when = .schedule
            darkView.isHidden = false
            scheduleTextField.becomeFirstResponder()
        default:
            break
        }
        selectBiWeeklyIfNeeded()
    }
    
    @IBAction func nowButtonTouchDown(_ sender: UIButton) {
        up2HoursLabel.alpha = 0.2
    }
    
    @IBAction func nowButtonTouchUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.up2HoursLabel.alpha = 1
        }
    }
    
    @IBAction func frequencyButtonClicked(_ sender: UIButton) {
        frequencyButtons.forEach({ $0.isSelected = false })
        sender.isSelected = true
        switch sender {
        case self.oneTimeButton:
            viewModel.rx_task.value.frequency = .oneTime
        case self.weeklyButton:
            viewModel.rx_task.value.frequency = .weekly
        case self.biWeeklyButton:
            viewModel.rx_task.value.frequency = .biweekly
        default:
            break
        }
    }
    
    @IBAction func lawnSizeButtonClicked(_ sender: UIButton) {
        lawnSizeButtons.forEach({ $0.isSelected = false })
        sender.isSelected = true
        lawnSizeLabels.forEach({ self.adjustButtonAdditionalLabel($0, selected: false) })
        switch sender {
        case self.lawnSizeSmallButton:
            viewModel.rx_task.value.lawnSize = .small
            adjustButtonAdditionalLabel(lawnSizeSmallLabel, selected: true)
        case self.lawnSizeMediumButton:
            viewModel.rx_task.value.lawnSize = .medium
            adjustButtonAdditionalLabel(lawnSizeMediumLabel, selected: true)
        case self.lawnSizeLargeButton:
            viewModel.rx_task.value.lawnSize = .large
            adjustButtonAdditionalLabel(lawnSizeLargeLabel, selected: true)
        default:
            break
        }
        selectBiWeeklyIfNeeded()
    }
    
    @IBAction func confirmServiceButtonClicked(_ sender: UIButton) {
        let task = viewModel.rx_task.value
        guard !task.isRecurring || MainViewController.shared.subscriptionsViewModel.allowsCreateSubscription(to: task.location) else {
            SVProgressHUD.showError(withStatus: "You already have subscription to this address.")
            return
        }
        sender.isUserInteractionEnabled = false
        SVProgressHUD.show()
        viewModel.submitTask() { (taskViewModel, error) in
            sender.isUserInteractionEnabled = true
            if let taskViewModel = taskViewModel {
                SVProgressHUD.showSuccess(withStatus: "Pending")
                self.delegate?.lawnServiceViewController(self, didSubmitTask: taskViewModel)
            } else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    @IBAction func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        swipe(sender: sender)
    }
    
    @IBAction func ccNumberButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Payment, sender: self)
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if scrollView.contentOffset.y < 0 || previousSwipingPoint != nil {
                scrollView.contentOffset.y = 0
            }
        }
    }
}

protocol LawnServiceViewControllerDelegate: NSObjectProtocol {
    func lawnServiceViewController(_ lawnServiceViewController: LawnServiceViewController, didSubmitTask taskDetailsViewModel: TaskDetailsViewModel)
}
