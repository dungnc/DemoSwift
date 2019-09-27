//
//  MainViewController.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 4/20/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController, MenuViewControllerDelegate {

    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var swipeView: MainSwipeView!
    @IBOutlet weak var hiddenView: UIView!
    
    static var shared: MainViewController!
    open var activeTasksViewModel: TasksViewModel!
    open var completeTasksViewModel: TasksViewModel!
    open var propertiesViewModel: PropertiesViewModel!
    open var subscriptionsViewModel: SubscriptionsViewModel!
    open var currentViewController: UIViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        MainViewController.shared = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Customer.current == nil && Auth.auth().currentUser != nil {
            Customer.current = Customer.load()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentViewController == nil && Customer.current != nil {
            let menuViewController = self.childViewControllers.first as! MenuViewController
            menuViewController.delegate = self
            menuViewController.selectMenuSection(.Home)
            PushNotificationManager.shared.requestAuthorization()
            activeTasksViewModel = TasksViewModel(mode: .Active)
            completeTasksViewModel = TasksViewModel(mode: .Complete)
            propertiesViewModel = PropertiesViewModel()
            subscriptionsViewModel = SubscriptionsViewModel()
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Home, sender: self)
            swipeView.hideMenu(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Customer.current == nil {
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Onboarding, sender: self)
        }
    }
    
    // MARK: - Public Methods
    
    open func logout() {
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Onboarding, sender: self)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParentViewController()
        currentViewController = nil
        activeTasksViewModel = nil
        completeTasksViewModel = nil
        propertiesViewModel = nil
        subscriptionsViewModel = nil
        let userId = Customer.current!.id
        Customer.current!.logout()
        ImageCacheManager.removeCachedPhoto(forUserId: userId)
    }
    
    open func showMenu() {
        swipeView.showMenu()
    }
    
    func contactSupport() {
        let alertController = UIAlertController(title: "Contact Support",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        let emailAction = UIAlertAction(title: "Email", style: .default) { (_) in
            MessagesHelper.showMailComposeViewController(recipient: K.SupportContact.Email, in: self)
        }
        let messageAction = UIAlertAction(title: "Message", style: .default) { (_) in
            MessagesHelper.showMessageComposeViewController(recipient: K.SupportContact.Phone, in: self)
        }
        let callAction = UIAlertAction(title: "Call", style: .default) { (_) in
            UIApplication.shared.open(URL(string: "tel://\(K.SupportContact.Phone)")!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(emailAction)
        alertController.addAction(messageAction)
        alertController.addAction(callAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - MenuViewControllerDelegate
    
    func menuViewController(_ menuViewController: MenuViewController, didSelectMenuSection menuSection: MenuSection) {
        switch menuSection {
        case .ViewProfile:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Settings, sender: self)
            swipeView.hideMenu(animated: true)
        case .Home:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Home, sender: self)
            swipeView.hideMenu(animated: true)
        case .Properties:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Properties, sender: self)
            swipeView.hideMenu(animated: true)
        case .TaskHistory:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.TaskHistory, sender: self)
            swipeView.hideMenu(animated: true)
        case .Payment:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Payment, sender: self)
            swipeView.hideMenu(animated: true)
        case .GetFreeService:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.GetFreeService, sender: self)
            swipeView.hideMenu(animated: true)
        case .Help:
            contactSupport()
        case .Settings:
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Settings, sender: self)
            swipeView.hideMenu(animated: true)
        }
    }
}
