//
//  FaceView.swift
//  Hppiness
//
//  Created by тигренок  on 10/12/15.
//  Copyright (c) 2015 Midori.s. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForeFaceView(sender: FaceView) -> Double?
}

@IBDesignable

class FaceView: UIView {
    
    
    @IBInspectable
    var lineWith : CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color : UIColor = UIColor.blueColor() {didSet {setNeedsDisplay()}}
    @IBInspectable
    var scale : CGFloat = 0.90 {didSet {setNeedsDisplay()}}
    
    
    private var faceCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    private var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    // public (non-private) delegate property
    // anyone who wants to provide our View's data
    // should just set themselves to be this property
    weak var dataSource: FaceViewDataSource?
    
    
    // gesture handler for pinching
    // non-private so that Controllers can create a recognizer for pinch
    // and then add it to us if they want us to support pinching
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    
    // the rest of this class is the code to draw the face

    override func drawRect(rect: CGRect) {
        
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle:CGFloat(2*M_PI), clockwise: true)
        
        facePath.lineWidth = lineWith
        color.set()
        facePath.stroke()
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        
        // get the smiliness from our dataSource delegate
        // smiliness will default to zero if either the dataSource is nil or the dataSource returns nil
        let smiliness = dataSource?.smilinessForeFaceView(self) ?? 0.0
        let smilePath = bezierPathForSmile(smiliness)
        smilePath.stroke()
    }

    
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye { case Left, Right }
    
    private func bezierPathForEye(wihichEye: Eye) -> UIBezierPath {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizintalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        switch wihichEye {
        case .Left: eyeCenter.x -= eyeHorizintalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizintalSeparation / 2
            
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = lineWith
        return path
        
    }
    
    private func bezierPathForSmile(fractionOfSmile: Double) -> UIBezierPath {
        
        let mouthWith = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHight = CGFloat(max(min(fractionOfSmile, 1), -1)) * mouthHight
        
        let start = CGPoint(x: faceCenter.x - mouthWith / 2 , y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWith, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWith / 3 , y: start.y + smileHight)
        let cp2 = CGPoint(x: end.x - mouthWith / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWith
        return path
        
        
    }

 
    

}
