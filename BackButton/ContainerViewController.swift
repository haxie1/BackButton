    //
//  ContainerViewController.swift
//  BackButton
//
//  Created by Kam Dahlin on 9/11/16.
//  Copyright © 2016 Kam Dahlin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    fileprivate var managedNavBarController: ManagedBackButtonNavController? {
        return self.childControllers.last as? ManagedBackButtonNavController
    }
    
    private var childControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // setup a fake navigation item on the Right side (content) child view controller
        // for sake of sample project, assume a nav controller
        if let rightVC = self.managedNavBarController as? UINavigationController {
            rightVC.manage {
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
    private class CopyWrapper: NSObject, NSCopying {
        var closure: (() -> Void)?
        
        convenience init(closure: (() -> Void)?) {
            self.init()
            self.closure = closure
        }
        
        func copy(with zone: NSZone? = nil) -> Any {
            let wrapper: CopyWrapper = CopyWrapper()
            wrapper.closure = closure
            
            return wrapper
        }
    }
    
    protocol ManagedBackButtonNavController: class {
        var backButtonTitle: String { get set }
        func manage(usingBackButtonHandler handler: @escaping () -> Void)
    }
    
    extension UINavigationController: ManagedBackButtonNavController, UINavigationBarDelegate {
        @nonobjc static var backButtonActionKey: String = "backButtonKey"
        @nonobjc static var registered: Bool = false
        
        var backButtonTitle: String {
            set (newValue) {
                if UINavigationController.registered {
                    self.navigationBar.items?.first?.title = newValue
                }
            }
            get {
                return self.navigationBar.items?.first?.title ?? "Back"
            }
        }
        
        internal func manage(usingBackButtonHandler handler: @escaping () -> Void) {
            if !UINavigationController.registered {
                UINavigationController.registered = true
                
                self.navigationBar.items?.insert(UINavigationItem(title: self.backButtonTitle), at: 0)
                if self.navigationBar.delegate == nil {
                    self.navigationBar.delegate = self
                }
                
                self.backButtonHandler = handler
            }
        }
        
        private var backButtonHandler: () -> Void {
            set (newValue) {
                let closure = CopyWrapper(closure: newValue)
                objc_setAssociatedObject(self, &UINavigationController.backButtonActionKey, closure, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            
            get {
                let closure = objc_getAssociatedObject(self, &UINavigationController.backButtonActionKey) as? CopyWrapper
                return closure?.closure ?? { _ in }
            }
        }

        
        public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
            if self.childViewControllers.count > 1 {
                self.popViewController(animated: true)
                return true
            }
            
            // Recreate the fake back button item so that the button is refreshed after being pressed.
            // re-add the fake item and the exiting item to the items array so that the navigation bar is correct when re-presented.
            let first = UINavigationItem(title: self.backButtonTitle)
            navigationBar.items = [first, item]
            self.backButtonHandler()
            
            return false
        }

    }
    
