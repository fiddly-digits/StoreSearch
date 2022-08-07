//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Roberto Cruz on 05/08/22.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            let time = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: time) {
                fromView.alpha = 0
            } completion: { finished in
                transitionContext.completeTransition(finished)
            }

        }
    }
}
