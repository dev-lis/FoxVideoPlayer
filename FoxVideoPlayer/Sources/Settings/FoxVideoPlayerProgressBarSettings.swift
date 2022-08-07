//
//  FoxVideoPlayerProgressBarSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 08.08.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSettings {
    
    var startRate: Float
    var screenMode: FoxScreenMode
    var isEnableHandleRotation: Bool
    
    var barHeight: CGFloat
//    var elementTopInset: CGFloat
    var timerLeftInset: CGFloat
    var buttonsStackRightInset: CGFloat
    
    var timerLabelColor: UIColor
    
    var timerLabelFont: UIFont
    
    var animateDuration: TimeInterval
    var elementAnimateDuration: TimeInterval
    
    var sliderSettings: FoxVideoPlayerProgressBarSliderSettings
    
    public init(startRate: Float = 1.0,
                screenMode: FoxScreenMode = .default,
                isEnableHandleRotation: Bool = true,
                barHeight: CGFloat = 66.0,
//                elementTopInset: CGFloat = 16.0,
                timerLeftInset: CGFloat = 24.0,
                buttonsStackRightInset: CGFloat = 24.0,
                timerLabelColor: UIColor = .white,
                timerLabelFont: UIFont = .systemFont(ofSize: 14, weight: .semibold),
                animateDuration: TimeInterval = 0.2,
                elementAnimateDuration: TimeInterval = 0.1,
                sliderSettings: FoxVideoPlayerProgressBarSliderSettings? = nil) {
        self.startRate = startRate
        self.screenMode = screenMode
        self.isEnableHandleRotation = isEnableHandleRotation
        self.barHeight = barHeight
        self.timerLeftInset = timerLeftInset
        self.buttonsStackRightInset = buttonsStackRightInset
        self.timerLabelColor = timerLabelColor
        self.timerLabelFont = timerLabelFont
        self.animateDuration = animateDuration
        self.elementAnimateDuration = elementAnimateDuration
        self.sliderSettings = sliderSettings ?? FoxVideoPlayerProgressBarSliderSettings()
    }
}
