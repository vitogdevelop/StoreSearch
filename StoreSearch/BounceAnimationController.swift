//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by vito on 14/08/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 1.0
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
      
      if let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
        
        toView.frame = transitionContext.finalFrameForViewController(toViewController)
        
        let containerView = transitionContext.containerView()
        containerView.addSubview(toView)
        
        toView.transform = CGAffineTransformMakeScale(0.7, 0.7)
        
        UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CalculationModeCubic, animations: {
          UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: {
            toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
          })
          UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
            toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
          })
          UIView.addKeyframeWithRelativeStartTime(0.666, relativeDuration: 0.333, animations: {
            toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
          })
          }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
     
      }
    }
  }
}
