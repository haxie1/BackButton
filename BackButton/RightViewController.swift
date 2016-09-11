//
//  RightViewController.swift
//  BackButton
//
//  Created by Kam Dahlin on 9/11/16.
//  Copyright © 2016 Kam Dahlin. All rights reserved.
//

import UIKit

class RightViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = self.navigationController?.childViewControllers.index(of: self) ?? 0
        self.title = "Content Level: \(index + 1)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
 

}
