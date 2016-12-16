//
//  GraphicSplitViewController.swift
//  Calculator
//
//  Created by 李天培 on 16/9/22.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

class GraphicSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    
}
