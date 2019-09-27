//
//  MainViewControllerSegue.swift
//  DaoFlowers
//
//  Created by Nguyen Chi Dung on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MainViewControllerSegue: UIStoryboardSegue {
    
    override func perform() {
        let mainViewController = self.source as! MainViewController
        let destinationViewController = self.destination as! UINavigationController
        
        if mainViewController.currentViewController != nil {
            mainViewController.currentViewController?.willMove(toParentViewController: nil)
            mainViewController.currentViewController?.view.removeFromSuperview()
            mainViewController.currentViewController?.removeFromParentViewController()
        }
        
        mainViewController.addChildViewController(destinationViewController)
        mainViewController.contentContainerView.addSubview(destinationViewController.view)
        destinationViewController.didMove(toParentViewController: mainViewController)
        mainViewController.currentViewController = destinationViewController
    }
}
