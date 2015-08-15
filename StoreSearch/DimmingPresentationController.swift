//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by vito on 08/08/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  
  lazy var dimmingView = GradientView(frame: CGRect.zeroRect)
  
  override func presentationTransitionWillBegin() {
    dimmingView.frame = containerView.bounds
    
    containerView.insertSubview(dimmingView, atIndex: 0)
    
    dimmingView.alpha = 0
    
    if let transitionCoordinator = presentedViewController.transitionCoordinator() {
      transitionCoordinator.animateAlongsideTransition({ _ in
        self.dimmingView.alpha = 1
        }, completion: nil)
    }
  }
  
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
  
  override func dismissalTransitionWillBegin() {
    if let transitionCoordinator = presentedViewController.transitionCoordinator() {
      transitionCoordinator.animateAlongsideTransition({ _ in
        self.dimmingView.alpha = 0
      }, completion: nil)
    }
  }
}
