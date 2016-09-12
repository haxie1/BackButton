    //
//  ContainerViewController.swift
//  BackButton
//
//  Created by Kam Dahlin on 9/11/16.
//  Copyright © 2016 Kam Dahlin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    fileprivate let fakeBackItem = UINavigationItem() // create a fake back item with the default title
    fileprivate var managedNavBarController: UINavigationController? {
        return self.childControllers.last as? UINavigationController
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
            var items = rightVC.navigationBar.items ?? []
            items.insert(self.fakeBackItem, at: 0)
            rightVC.navigationBar.setItems(items, animated: false)
            rightVC.navigationBar.delegate = self
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let leftVC = self.childViewControllers.first {
            self.fakeBackItem.title = leftVC.title
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

extension ContainerViewController: UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        // A fake item was added above the navigation item of the rootViewController of the right side navigation controller and we need to manage the pop action between the two items.
        
        if let managedNav = self.managedNavBarController {
            if managedNav.topViewController == managedNav.childViewControllers.first {
                
                self.popContent()
                return false
            }
            
            // need to manage poping the navigation controller's child controllers ourselves.
            managedNav.popViewController(animated: true)
        }
    
        return true
    }
}

enum NavigationType {
    case pop
    case push
}
