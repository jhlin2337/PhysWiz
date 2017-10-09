//
//  MenuTransitionManager.swift
//  SlideMenu
//
//  Created by Simon Ng on 19/10/2015.
//  Copyright © 2015 AppCoda. All rights reserved.
//

import UIKit

@objc protocol MenuTransitionManagerDelegate {
}

class MenuTransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    let duration = 0.5
    var isPresenting = false
    
    var snapshot:UIView? {
        didSet {
            }
        }
    
    var delegate:MenuTransitionManagerDelegate?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Get reference to our fromView, toView and the container view
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        // Set up the transform we'll use in the animation
        guard let container = transitionContext.containerView() else {
            return
        }
        let moveUp = CGAffineTransformMakeTranslation(0, -100)
        let moveDown = CGAffineTransformMakeTranslation(0, 0)
        toView.frame = CGRectMake(0, 0, fromView.frame.width, 100)
        // Add both views to the container view
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
        }
        
        // Perform the animation
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            if self.isPresenting {
                fromView.transform = CGAffineTransformMakeScale(1.0, 0.8)
                toView.transform = moveUp
            } else {
                self.snapshot?.transform = CGAffineTransformIdentity
                fromView.transform = moveDown
            }
            
            }, completion: { finished in
                
                transitionContext.completeTransition(true)

                if !self.isPresenting {
                    self.snapshot?.removeFromSuperview()
                }
        })
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = false
        return self
    }

}
