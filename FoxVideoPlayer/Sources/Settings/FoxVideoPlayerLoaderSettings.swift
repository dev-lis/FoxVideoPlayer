//
//  FoxVideoPlayerLoaderSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 16.08.2022.
//

import UIKit

public struct FoxVideoPlayerLoaderSettings {
    
    let style: UIActivityIndicatorView.Style
    let color: UIColor
    let size: Size
    
    public init(style: UIActivityIndicatorView.Style = .large,
                color: UIColor = .white,
                size: Size = Size()) {
        self.style = style
        self.color = color
        self.size = size
    }
}

extension FoxVideoPlayerLoaderSettings {
    public struct Size {
        let centerXInset: CGFloat
        let centerYInset: CGFloat
        
        public init(centerXInset: CGFloat = 0,
                    centerYInset: CGFloat = 0) {
            self.centerXInset = centerXInset
            self.centerYInset = centerYInset
        }
    }
}
