//
//  FoxVideoPlayerProgressBarSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 31.03.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSettings {
    
    public var barHeight: CGFloat
    public var timerLeftInset: CGFloat
    public var buttonsStackRightInset: CGFloat
    
    public var timerLabelColor: UIColor
    
    public var timerLabelFont: UIFont
    
    public var sliderSettings: FoxVideoPlayerProgressBarSliderSettings
    
    public init(barHeight: CGFloat = 66.0,
                timerLeftInset: CGFloat = 24.0,
                buttonsStackRightInset: CGFloat = 24.0,
                timerLabelColor: UIColor = .white,
                timerLabelFont: UIFont = .systemFont(ofSize: 14, weight: .semibold),
                sliderSettings: FoxVideoPlayerProgressBarSliderSettings? = nil) {
        self.barHeight = barHeight
        self.timerLeftInset = timerLeftInset
        self.buttonsStackRightInset = buttonsStackRightInset
        self.timerLabelColor = timerLabelColor
        self.timerLabelFont = timerLabelFont
        self.sliderSettings = sliderSettings ?? FoxVideoPlayerProgressBarSliderSettings()
    }
}
