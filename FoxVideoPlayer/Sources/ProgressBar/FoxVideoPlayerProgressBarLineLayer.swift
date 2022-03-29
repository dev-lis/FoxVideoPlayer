//
//  FoxVideoPlayerProgressBarLineLayer.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

class FoxVideoPlayerProgressBarLineLayer: CALayer {
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var value: CGFloat {
        bounds.width * progress
    }
    
    var fillColor: UIColor?
    
    override func draw(in ctx: CGContext) {
        guard let fillColor = fillColor else { return }
        ctx.setFillColor(fillColor.cgColor)
        let rect = CGRect(x: 0, y: 0, width: value, height: bounds.height)
        ctx.fill(rect)
    }
}
