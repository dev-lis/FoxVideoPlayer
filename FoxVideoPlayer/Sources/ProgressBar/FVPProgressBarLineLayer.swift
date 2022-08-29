//
//  FVPProgressBarLineLayer.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

class FVPProgressBarLineLayer: CALayer {
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var value: CGFloat {
        bounds.width * progress
    }

    override func draw(in ctx: CGContext) {
        ctx.setFillColor(UIColor.systemBlue.cgColor)
        let rect = CGRect(x: 0, y: 0,
                          width: value,
                          height: bounds.height)
        ctx.fill(rect)
    }
}
