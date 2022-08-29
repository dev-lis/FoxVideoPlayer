//
//  FVPProgressBarSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 08.08.2022.
//

import Foundation

public struct FVPProgressBarSettings {
    
    let startRate: Float
    let screenMode: FVPScreenMode
    
    let color: Color
    let font: Font
    let size: Size
    let duration: Duration
    let flag: Flag
    
    public init(startRate: Float = 1.0,
                screenMode: FVPScreenMode = .default,
                color: Color = Color(),
                font: Font = Font(),
                size: Size = Size(),
                duration: Duration = Duration(),
                flag: Flag = Flag()) {
        self.startRate = startRate
        self.screenMode = screenMode
        self.color = color
        self.font = font
        self.size = size
        self.duration = duration
        self.flag = flag
    }
}

extension FVPProgressBarSettings {
    public struct Color {
        let timer: UIColor
        
        public init(timer: UIColor = .white) {
            self.timer = timer
        }
    }
}

extension FVPProgressBarSettings {
    public struct Font {
        let timer: UIFont
        
        public init(timer: UIFont = .systemFont(ofSize: 14, weight: .semibold)) {
            self.timer = timer
        }
    }
}

extension FVPProgressBarSettings {
    public struct Size {
        let barHeight: CGFloat
        let timerLeftInset: CGFloat
        let buttonsStackRightInset: CGFloat
        
        public init(barHeight: CGFloat = 66.0,
                    timerLeftInset: CGFloat = 24.0,
                    buttonsStackRightInset: CGFloat = 24.0) {
            self.barHeight = barHeight
            self.timerLeftInset = timerLeftInset
            self.buttonsStackRightInset = buttonsStackRightInset
        }
    }
}

extension FVPProgressBarSettings {
    public struct Duration {
        let animate: TimeInterval
        let elementAnimate: TimeInterval
        
        public init(animate: TimeInterval = 0.2,
                    elementAnimate: TimeInterval = 0.1) {
            self.animate = animate
            self.elementAnimate = elementAnimate
        }
    }
}

extension FVPProgressBarSettings {
    public struct Flag {
        let isEnableHandleRotation: Bool
        let isVisibleProgressOnHiddenState: Bool
        
        public init(isEnableHandleRotation: Bool = true,
                    isVisibleProgressOnHiddenState: Bool = true) {
            self.isEnableHandleRotation = isEnableHandleRotation
            self.isVisibleProgressOnHiddenState = isVisibleProgressOnHiddenState
        }
    }
}
