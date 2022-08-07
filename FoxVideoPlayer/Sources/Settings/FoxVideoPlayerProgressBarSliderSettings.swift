//
//  FoxVideoPlayerProgressBarSliderSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 30.03.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSliderSettings {
    let sliderHeight: CGFloat
    let sideInsetsOnShownState: CGFloat
    let pinDefaultSize: CGFloat
    let pinIncreasedSize: CGFloat
    let previewLabelBottomInset: CGFloat
    let previewImageBottomInset: CGFloat
    
    let sliderBackgroundColor: UIColor
    let sliderFillColor: UIColor
    let previewTimeLabelColor: UIColor
    
    let previewTimeLabelFont: UIFont
    
    let animateDuration: TimeInterval
    
    let isRoundedCornersSlider: Bool
    let isEnableVibrate: Bool
    
    public init(sliderHeight: CGFloat = 4.0,
                sideInsetsOnShownState: CGFloat = 16.0,
                pinDefaultSize: CGFloat = 12.0,
                pinIncreasedSize: CGFloat = 20.0,
                previewLabelBottomInset: CGFloat = 8.0,
                previewImageBottomInset: CGFloat = 8.0,
                sliderBackgroundColor: UIColor = .white.withAlphaComponent(0.44),
                sliderFillColor: UIColor = .systemBlue,
                previewTimeLabelColor: UIColor = .white,
                previewTimeLabelFont: UIFont = .systemFont(ofSize: 18, weight: .medium),
                animateDuration: TimeInterval = 0.2,
                isRoundedCornersSlider: Bool = true,
                isEnableVibrate: Bool = true) {
        self.sliderHeight = sliderHeight
        self.sideInsetsOnShownState = sideInsetsOnShownState
        self.pinDefaultSize = pinDefaultSize
        self.pinIncreasedSize = pinIncreasedSize
        self.previewLabelBottomInset = previewLabelBottomInset
        self.previewImageBottomInset = previewImageBottomInset
        self.sliderBackgroundColor = sliderBackgroundColor
        self.sliderFillColor = sliderFillColor
        self.previewTimeLabelColor = previewTimeLabelColor
        self.previewTimeLabelFont = previewTimeLabelFont
        self.animateDuration = animateDuration
        self.isRoundedCornersSlider = isRoundedCornersSlider
        self.isEnableVibrate = isEnableVibrate
    }
}
