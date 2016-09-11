//
//  ContainerViewController.swift
//  BackButton
//
//  Created by Kam Dahlin on 9/11/16.
//  Copyright © 2016 Kam Dahlin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // setup a fake navigation item on the Right side (content) child view controller
        // for sake of sample project, assume a nav controller
        if let rightVC = self.childViewControllers.last as? UINavigationController, let leftVC = self.childViewControllers.first as? UINavigationController {
            
            // insert the fake item in the rightVC navigation bar.items at the top index.
            // this is what makes the nav bar believe it should show a back button
            let fakeItem = UINavigationItem(title: leftVC.title ?? "Back")
            rightVC.navigationBar.items?.insert(fakeItem, at: 0)
            
            // our ourselves as the delegate so we can manage the navigation bar items ourselves.
            rightVC.navigationBar.delegate = self
            
        }
    }
    
    @IBAction func pushContent(_ sender: AnyObject) {
        
    }
    
    func addChildControllers(controllers: [UIViewController]) {
        for (index, controller) in controllers.enumerated() {
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
}

extension ContainerViewController: UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        // A fake item was added above the navigation item of the rootViewController of the right side navigation controller and we need to manage the pop action between the two items.
        
        if navigationBar.items?.count == 2 {
            // this is our hook to handle the back navigation.
            // for production this should probably be a beefier check, but the idea is that we don't want to pop to the fake navigation item
            return false
        }
        
        // let other items get handled normally.
        return true
    }
}
