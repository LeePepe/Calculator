//
//  GraphicViewController.swift
//  Calculator
//
//  Created by 李天培 on 16/9/22.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

class GraphicViewController: UIViewController, CalculatorGraphicViewDataSource {
    // MARK: - outlet
    @IBOutlet weak var graphicView: CalculatorGraphicView! {
        didSet {
            let panRecognizer = UIPanGestureRecognizer(target: graphicView, action: #selector(CalculatorGraphicView.moveGraph(gesture:)))
            graphicView.addGestureRecognizer(panRecognizer)
            
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphicView, action: #selector(CalculatorGraphicView.pinchGraph(gesture:)))
            graphicView.addGestureRecognizer(pinchRecognizer)
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphicView, action: #selector(CalculatorGraphicView.doubleTap(gesture:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphicView.addGestureRecognizer(doubleTapRecognizer)
            
            updateUI()
        }
    }

    var brain = CalculatorBrain()
    
    var origin: CGPoint?
    var scale: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        graphicView.datasource = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let info = UserDefaults.standard.dictionary(forKey: "GraphInfo") {
            if let originX = info["originX"] as? CGFloat {
                if let originY = info["originY"] as? CGFloat {
                    graphicView.origin = CGPoint(x: originX, y: originY)
                }
            }
            if let scale = info["scale"] as? CGFloat {
                graphicView.pointsPerUnit = scale
            }
        }
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let propertyList = [
            "originX" : origin.x,
            "originY" : origin.y,
            "scale" : scale
        ]
        
        UserDefaults.standard.set(propertyList, forKey: "GraphInfo")
    }
    
    func yBy(x: CGFloat, sender: CalculatorGraphicView) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        if brain.result.isNormal || brain.result.isZero {
            return CGFloat(brain.result)
        } else {
            return nil
        }
    }
    
    fileprivate func updateUI() {
        graphicView?.setNeedsDisplay()
        title = brain.description
    }

}
