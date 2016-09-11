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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

