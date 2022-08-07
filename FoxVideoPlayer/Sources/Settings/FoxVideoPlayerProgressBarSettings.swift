//
//  FoxVideoPlayerProgressBarSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 08.08.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSettings {
    
    let startRate: Float
    let screenMode: FoxScreenMode
    let isEnableHandleRotation: Bool
    
    let barHeight: CGFloat
    let timerLeftInset: CGFloat
    let buttonsStackRightInset: CGFloat
    
    let timerLabelColor: UIColor
    
    let timerLabelFont: UIFont
    
    let animateDuration: TimeInterval
    let elementAnimateDuration: TimeInterval
    
    public init(startRate: Float = 1.0,
                screenMode: FoxScreenMode = .default,
                isEnableHandleRotation: Bool = true,
                barHeight: CGFloat = 66.0,
                timerLeftInset: CGFloat = 24.0,
                buttonsStackRightInset: CGFloat = 24.0,
                timerLabelColor: UIColor = .white,
                timerLabelFont: UIFont = .systemFont(ofSize: 14, weight: .semibold),
                animateDuration: TimeInterval = 0.2,
                elementAnimateDuration: TimeInterval = 0.1) {
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
    }
}
