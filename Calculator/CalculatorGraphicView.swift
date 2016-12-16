//
//  CalculatorGraphicView.swift
//  Calculator
//
//  Created by 李天培 on 16/9/22.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit


protocol CalculatorGraphicViewDataSource {
    func yBy(x: CGFloat, sender: CalculatorGraphicView) -> CGFloat?
}

@IBDesignable
class CalculatorGraphicView: UIView {
    
    var axesDrawer = AxesDrawer()
    
    var datasource: CalculatorGraphicViewDataSource?
    
    fileprivate var originOffset = CGPoint.zero { didSet { setNeedsDisplay() } }
    
    var origin: CGPoint {
        get {
            return CGPoint(x: bounds.maxX / 2.0 + originOffset.x,
                           y: bounds.maxY / 2.0 + originOffset.y)
        }
        set {
            print(CGPoint(x: newValue.x - bounds.maxX / 2.0,
                          y: newValue.y - bounds.maxY / 2.0), bounds)
            originOffset = CGPoint(x: newValue.x - bounds.maxX / 2.0,
                                   y: newValue.y - bounds.maxY / 2.0)
        }
    }
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 100 { didSet { setNeedsDisplay() } }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing Axes
        axesDrawer.drawAxesInRect(bounds: bounds,
                                  origin: origin,
                                  pointsPerUnit: pointsPerUnit)
        
        // Drawing Graph
        drawGraph(origin: origin, pointsPerUnit: pointsPerUnit)
    }
    
    func drawGraph(origin: CGPoint, pointsPerUnit: CGFloat)  {
        let path = UIBezierPath()
        
        var graphicX = bounds.minX
        while graphicX <= bounds.maxX {
            let x = (graphicX - origin.x) / pointsPerUnit
            
            
            if let y = datasource?.yBy(x: x, sender: self) {
                let convertedPoint = CGPoint(x: graphicX, y: origin.y - y * pointsPerUnit)
                
                if bounds.contains(convertedPoint) {
                    path.addLine(to: convertedPoint)
                }
                path.move(to: convertedPoint)
            }
            graphicX += 1 / contentScaleFactor
        }
        path.stroke()
    }
    
    // MARK: - Gesture
    @objc func moveGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            let translation = gesture.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            gesture.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    @objc func pinchGraph(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            pointsPerUnit *= gesture.scale
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    @objc func doubleTap(gesture: UITapGestureRecognizer) {
        let origin = gesture.location(in: self)
        self.origin = origin
    }

}
