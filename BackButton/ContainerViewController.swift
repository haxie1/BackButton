    //
//  ContainerViewController.swift
//  BackButton
//
//  Created by Kam Dahlin on 9/11/16.
//  Copyright © 2016 Kam Dahlin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    fileprivate var managedNavBarController: ManagedNavBarNavController? {
        return self.childControllers.last as? ManagedNavBarNavController
    }
    
    private var childControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setup a fake navigation item on the Right side (content) child view controller
        // for sake of sample project, assume a nav controller
        
        if let rightVC = self.managedNavBarController {
            rightVC.handleBackButtonTap = {
                self.popContent()
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let leftVC = self.childViewControllers.first {
            self.managedNavBarController?.backButtonTitle = leftVC.title ?? "Back"
        }
    }
    
    @IBAction func pushContent(_ sender: AnyObject) {
        self.performNavigation(type: .push)
    }
    
    func popContent() {
        self.performNavigation(type: .pop)
    }
    
    func addChildControllers(controllers: [UIViewController]) {
        self.childControllers = controllers
        
        for (index, controller) in controllers.enumerated() {
            self.insertChildController(controller: controller, at: index)
        }
    }
    
    private func insertChildController(controller: UIViewController, at index: Int) {
        if !self.childViewControllers.contains(controller) {
            self.addChildViewController(controller)
            self.view.insertSubview(controller.view, at: index)
            controller.view.frame = self.view.bounds
            
            if index == 0 {
                // push the left side view controller off screen
                controller.view.frame.origin.x = self.view.bounds.width * -1
            }
            
            controller.didMove(toParentViewController: self)
        }
    }
    
    private func removeChildController(controller: UIViewController) {
        if self.childViewControllers.contains(controller) {
            controller.willMove(toParentViewController: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }
    }
    
    private func performNavigation(type: NavigationType) {
        guard let leftVC = self.childControllers.first, let rightVC = self.childControllers.last else {
            return
        }
        
        let animator = self.animator(forType: type, leftController: leftVC, rightController: rightVC)
        animator?.startAnimation()
    }
    
    private func animator(forType type: NavigationType, leftController: UIViewController, rightController: UIViewController) -> UIViewPropertyAnimator? {
        let animator = UIViewPropertyAnimator(duration: 0.3, timingParameters: UISpringTimingParameters())
        switch type {
        case .push:
            self.insertChildController(controller: rightController, at: 1)
            rightController.view.frame.origin.x = self.view.bounds.width
            break
        case .pop:
            self.insertChildController(controller: leftController, at: 0)
            leftController.view.frame.origin.x = self.view.bounds.width * -1
            break
        }
        
        animator.addAnimations {
            switch type {
            case .pop:
                leftController.view.frame.origin.x = 0.0
                rightController.view.frame.origin.x = self.view.bounds.width
                break
            case .push:
                
                leftController.view.frame.origin.x = self.view.bounds.width * -1
                rightController.view.frame.origin.x = 0.0
                
                break
            }
        }
        
        animator.addCompletion { (position) in
            if position == .end {
                switch type {
                case .pop:
                    self.removeChildController(controller: rightController)
                    break
                    
                case .push:
                    self.removeChildController(controller: leftController)
                    break
                }
            }
        }
        return animator
    }
}

enum NavigationType {
    case pop
    case push
}

    
    // Trying to managed the navigation bar delegate with an object that isn't the nav bar's navigation controller makes the system angry. 
    // To work around this, make the navigation bar the delegate of the nav controller and handle the item setup and nav bar delegation with the nav controller.
    class ManagedNavBarNavController: UINavigationController, UINavigationBarDelegate {
        var backButtonTitle: String = "Back" {
            didSet {
                self.navigationBar.items?.first?.title = backButtonTitle
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let nav = UINavigationItem(title: self.backButtonTitle)
            self.navigationBar.items?.insert(nav, at: 0)
        }
        
        // custom handler that is called when the fake back button item is pressed.
        var handleBackButtonTap: () -> Void = {_ in}
        
        func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
            if self.childViewControllers.count > 1 {
                self.popViewController(animated: true)
                return true
            }
            
            // Recreate the fake back button item so that the button is refreshed after being pressed.
            // re-add the fake item and the exiting item to the items array so that the navigation bar is correct when re-presented.
            let first = UINavigationItem(title: self.backButtonTitle)
            navigationBar.items = [first, item]
            self.handleBackButtonTap()
            
            return false
        }
    }

