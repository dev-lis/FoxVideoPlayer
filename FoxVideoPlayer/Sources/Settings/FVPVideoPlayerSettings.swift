//
//  FVPVideoPlayerSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 30.08.2022.
//

import Foundation

public struct FVPVideoPlayerSettings {
    let rate: Float
    let color: Color
    
    public init(rate: Float = 1.0,
                color: Color = Color()) {
        self.rate = rate
        self.color = color
    }
}

extension FVPVideoPlayerSettings {
    public struct Color {
        let background: UIColor
        
        public init(background: UIColor = .black) {
            self.background = background
        }
    }
}
