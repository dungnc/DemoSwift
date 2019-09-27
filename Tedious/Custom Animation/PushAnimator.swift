//
//  PushAnimator.swift
//
//  Created by Nguyen Chi Dung on 3/3/18.
//  Copyright © 2018. All rights reserved.
//

import UIKit

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    deinit {
        print("PushAnimator deinit")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        let initialFrameFromVC = transitionContext.initialFrame(for: fromVC)
        let offsetXFinalFrameFromVC = -initialFrameFromVC.size.width
        let finalFrameFromVC = initialFrameFromVC.offsetBy(dx: offsetXFinalFrameFromVC, dy: 0)
        let finalFrameToVC = initialFrameFromVC
        let offsetXinitialFrameToVC = initialFrameFromVC.size.width
        let initialFrameToVC = initialFrameFromVC.offsetBy(dx: offsetXinitialFrameToVC, dy: 0)
        toVC.view.frame = initialFrameToVC
        containerView.addSubview(toVC.view)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = finalFrameFromVC
            toVC.view.frame = finalFrameToVC
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
