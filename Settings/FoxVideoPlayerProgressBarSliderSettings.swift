//
//  FoxVideoPlayerProgressBarSliderSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 30.03.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSliderSettings {
    public var sliderHeight: CGFloat
    public var sideInsetsOnShownState: CGFloat
    public var pinDefaultSize: CGFloat
    public var pinIncreasedSize: CGFloat
    
    public var sliderBackgroundColor: UIColor
    public var sliderFillColor: UIColor
    public var previewTimeLabelColor: UIColor
    
    public var previewTimeLabelFont: UIFont
    
    public var previewAnimateDuration: TimeInterval
    
    public var isRoundedCornersSlider: Bool
    public var isEnableVibrate: Bool
    
    public init(sliderHeight: CGFloat = 4.0,
                sideInsetsOnShownState: CGFloat = 16.0,
                pinDefaultSize: CGFloat = 12.0,
                pinIncreasedSize: CGFloat = 20.0,
                sliderBackgroundColor: UIColor = .white.withAlphaComponent(0.44),
                sliderFillColor: UIColor = .systemBlue,
                previewTimeLabelColor: UIColor = .white,
                previewTimeLabelFont: UIFont = .systemFont(ofSize: 18, weight: .medium),
                previewAnimateDuration: TimeInterval = 5,
                isRoundedCornersSlider: Bool = true,
                isEnableVibrate: Bool = true) {
        self.sliderHeight = sliderHeight
        self.sideInsetsOnShownState = sideInsetsOnShownState
        self.pinDefaultSize = pinDefaultSize
        self.pinIncreasedSize = pinIncreasedSize
        self.sliderBackgroundColor = sliderBackgroundColor
        self.sliderFillColor = sliderFillColor
        self.previewTimeLabelColor = previewTimeLabelColor
        self.previewTimeLabelFont = previewTimeLabelFont
        self.previewAnimateDuration = previewAnimateDuration
        self.isRoundedCornersSlider = isRoundedCornersSlider
        self.isEnableVibrate = isEnableVibrate
    }
}
