//
//  CounterView.swift
//  daysleft
//
//  Created by John Pollard on 19/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//  Based heavily on an article at http://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1

import UIKit
import daysleftlibrary

let π:CGFloat = CGFloat(M_PI)

@IBDesignable class CounterView: UIView {
    
    @IBInspectable var counter: Int = 5
    @IBInspectable var maximumValue: Int = 8
    @IBInspectable var outlineColor: UIColor = UIColor.blueColor()
    @IBInspectable var counterColor: UIColor = UIColor.orangeColor()
    
    override func drawRect(rect: CGRect) {
        // Define the center point of the view where you’ll rotate the arc around
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        // Calculate the radius based on the max dimension of the view
        let radius: CGFloat = max(bounds.width, bounds.height)
        
        // Define the thickness of the arc
        let arcWidth: CGFloat = 76
        
        // Define the start and end angles for the arc
        let startAngle: CGFloat = 3 * π / 4
        let endAngle: CGFloat = π / 4
        
        // Create a path based on the center point, radius, and angles you just defined
        var path = UIBezierPath(arcCenter: center,
            radius: bounds.width/2 - arcWidth/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        
        // Set the line width and color before finally stroking the path
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()
        
        // Draw the outline
        
        // First calculate the difference between the two angles
        // ensuring it is positive
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        
        // Then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(maximumValue)
        
        // Then multiply out by the actual glasses drunk
        let outlineEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle
        
        // Draw the outer arc
        var outlinePath = UIBezierPath(arcCenter: center,
            radius: bounds.width/2 - 2.5,
            startAngle: startAngle,
            endAngle: outlineEndAngle,
            clockwise: true)
        
        // Draw the inner arc
        outlinePath.addArcWithCenter(center,
            radius: bounds.width/2 - arcWidth + 2.5,
            startAngle: outlineEndAngle,
            endAngle: startAngle,
            clockwise: false)
        
        // Close the path
        outlinePath.closePath()
        
        outlineColor.setStroke()
        outlinePath.lineWidth = 5.0
        outlinePath.stroke()
    }
}
