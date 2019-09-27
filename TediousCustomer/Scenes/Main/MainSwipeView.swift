//
//  MainSwipeView.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 4/20/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit

class MainSwipeView: UIView {
    
    @IBOutlet weak var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    fileprivate var previousTouchPoint: CGPoint!
    
    fileprivate var isMenuOpened: Bool {
        return MainViewController.shared.menuContainerView.frame.origin.x == 0
    }
    
    fileprivate var menuContainerView: UIView {
        return MainViewController.shared.menuContainerView
    }
    fileprivate var contentContainerView: UIView {
        return MainViewController.shared.contentContainerView
    }

    // MARK: - Override Methods
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        var isSwipeAllowed: Bool = false
        let treshold: CGFloat = 13
        if isMenuOpened {
            panGestureRecognizer.isEnabled = true
        } else {
            panGestureRecognizer.isEnabled = false
            if point.x <= treshold {
                isSwipeAllowed = true
                screenEdgePanGestureRecognizer.isEnabled = true
            }
        }

        if isSwipeAllowed {
            return hitView
        } else {
            return nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(#function)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(#function)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(#function)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(#function)
    }
    
    // MARK: - Open Methods
    
    open func showMenu() {
        completeSwipeAnimation(forced: true, open: true)
    }
    
    open func hideMenu(animated: Bool) {
        if animated {
            completeSwipeAnimation(forced: true, open: false)
        } else {
            menuContainerView.frame.origin.x = -self.menuContainerView.frame.width
            contentContainerView.frame.origin.x = 0
            MainViewController.shared.hiddenView.alpha = 0
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate var progress: CGFloat {
        let progress = (menuContainerView.frame.width + menuContainerView.frame.origin.x) / menuContainerView.frame.width
        return progress
    }
    
    fileprivate func completeSwipeAnimation(forced: Bool = false, open: Bool = false) {
        var isOpening: Bool
        var duration: TimeInterval
        if forced {
            isOpening = open
            duration = 0.3
        } else {
            isOpening = progress > 0.4
            duration = TimeInterval(isOpening ? 1 - progress : progress) * 0.6
        }
        UIView.animate(withDuration: duration, animations: {
            if isOpening {
                self.menuContainerView.frame.origin.x = 0
                self.contentContainerView.frame.origin.x = 0.3 * self.contentContainerView.frame.width
                MainViewController.shared.hiddenView.alpha = 0.45
            } else {
                self.menuContainerView.frame.origin.x = -self.menuContainerView.frame.width
                self.contentContainerView.frame.origin.x = 0
                MainViewController.shared.hiddenView.alpha = 0
            }
        }) { (finished) in
            //MainViewController.shared.hiddenView.isHidden = !isMenuOpened
        }
    }
    
    func dragMenu(_ sender: UIGestureRecognizer) {
        let point: CGPoint = sender.location(in: sender.view)
        if self.previousTouchPoint != nil {
            let deltaX = point.x - self.previousTouchPoint.x
            if (menuContainerView.frame.origin.x + deltaX) <= 0 {
                menuContainerView.frame.origin.x += deltaX
                contentContainerView.frame.origin.x = 0.3 * contentContainerView.frame.width * progress
                MainViewController.shared.hiddenView.alpha = progress * 0.45
                if contentContainerView.frame.origin.x < 0 {
                    contentContainerView.frame.origin.x = 0
                }
            }
        }
        
        self.previousTouchPoint = point
        
        if sender.state == UIGestureRecognizerState.ended ||
            sender.state == UIGestureRecognizerState.cancelled {
            self.previousTouchPoint = nil
            completeSwipeAnimation()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        //print("\(#function)")
        hideMenu(animated: true)
    }
    
    @IBAction func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        //print("\(#function)")
        dragMenu(sender)
    }
    
    @IBAction func screenEdgePanGestureRecognized(_ sender: UIScreenEdgePanGestureRecognizer) {
        //print("\(#function)")
        let point = sender.location(in: sender.view)
        if (menuContainerView.frame.width - point.x) >= 0 {
            menuContainerView.frame.origin.x = -(menuContainerView.frame.width - point.x)
            contentContainerView.frame.origin.x = 0.3 * contentContainerView.frame.width * progress
            MainViewController.shared.hiddenView.alpha = progress * 0.45
        }
        if sender.state == UIGestureRecognizerState.ended ||
            sender.state == UIGestureRecognizerState.cancelled {
            completeSwipeAnimation()
        }
    }
}

