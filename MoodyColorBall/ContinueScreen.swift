//
//  ContinueScreen.swift
//  MoodyColorBall
//
//  Created by Sai Kasam on 2/11/18.
//  Copyright © 2018 DevHandles. All rights reserved.
//

import UIKit
import SpriteKit

class ContinueScreen: SKNode {
    
    static func removeContinueScreen(names: [String], view: UIView?, GameScene: GameScene){
        for name in names{
            GameScene.childNode(withName: name)?.removeFromParent()
        }
        for layer in (view?.layer.sublayers)! {
            if layer.name == "circleLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
    }

    static func animateCircle(frame: CGRect,view: UIView?) {
        let circleLayer: CAShapeLayer!
        
        
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: 70, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat(Double.pi * 1.499), clockwise: true)
        
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.backgroundColor = UIColor.clear.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0).cgColor
        circleLayer.lineWidth = 5.0
        
        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0
        
        circleLayer.name = "circleLayer"
        
        // Add the circleLayer to the view's layer's sublayers
        view?.layer.addSublayer(circleLayer)
        
        
        
        let duration: TimeInterval = 5
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0
        
        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
    }
    
    
    
    
    
    
    
    
}
