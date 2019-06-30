//
//  CounterView.swift
//  daysleft
//
//  Created by John Pollard on 19/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//  Based heavily on an article at http://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1

import UIKit

let π: CGFloat = CGFloat(Double.pi)

open class CounterView: UIView {
    
    @IBInspectable open var counter: Int = 5
    @IBInspectable open var maximumValue: Int = 8
    @IBInspectable open var arcWidth: CGFloat = 76
    @IBInspectable open var outlineColor: UIColor = UIColor.blue
    @IBInspectable open var counterColor: UIColor = UIColor.orange
    
    fileprivate var circleSubView: CAShapeLayer? = nil
    fileprivate var progressSubView: CAShapeLayer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clearControl()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clearControl()
    }
    
    open func clearControl() {
        // First clear circle view
        if self.circleSubView != nil {
            self.circleSubView?.removeFromSuperlayer()
            self.circleSubView = nil
        }
        
        // Then clear existing progress view
        if self.progressSubView != nil {
            self.progressSubView?.removeFromSuperlayer()
            self.progressSubView = nil
        }
    }
    
    open func updateControl() {
        self.clearControl()
        self.arcWidth = bounds.width / 3.0

        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
                
        // Define the start and end angles for the arc
        let startAngle: CGFloat = 3 * π / 4

        // Define the center point of the view where you’ll rotate the arc around
        let endAngle: CGFloat = π / 4

        if (self.circleSubView == nil) {
            self.circleSubView = CAShapeLayer(layer: self.layer)
        
            // Create a path based on the center point, radius, and angles you just defined
            let path = UIBezierPath(arcCenter: center,
                radius: bounds.width/2 - self.arcWidth/2,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true)

            self.circleSubView?.path = path.cgPath
            self.circleSubView?.fillColor = UIColor.clear.cgColor
            self.circleSubView?.strokeColor = self.counterColor.cgColor
            self.circleSubView?.lineWidth = self.arcWidth
            
            self.circleSubView?.shadowOffset = CGSize(width: 3.0, height: 3.0)
            self.circleSubView?.shadowOpacity = 0.25
            
            self.layer.addSublayer(self.circleSubView!)
        }
        
        // Now add the progress circle
        self.progressSubView = CAShapeLayer(layer: self.layer)
        
        // First calculate the difference between the two angles
        // ensuring it is positive
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        
        // Then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(maximumValue)
        
        // Then multiply out by the actual glasses drunk
        let progressEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle
        
        let progressPath = UIBezierPath(arcCenter: center,
            radius: bounds.width/2 - self.arcWidth/2,
            startAngle: startAngle,
            endAngle: progressEndAngle,
            clockwise: true)

        self.progressSubView?.path = progressPath.cgPath
        self.progressSubView?.fillColor = UIColor.clear.cgColor
        self.progressSubView?.strokeColor = self.outlineColor.cgColor
        self.progressSubView?.lineWidth = self.arcWidth

        self.layer.addSublayer(self.progressSubView!)
        
        // Now animate the progress drawing
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.isRemovedOnCompletion = true
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        self.progressSubView?.add(animation, forKey: "drawProgressAnimation")
    }
}
