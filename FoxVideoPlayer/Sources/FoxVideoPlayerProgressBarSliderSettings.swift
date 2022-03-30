//
//  FoxVideoPlayerProgressBarSliderSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 30.03.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSliderSettings {
    public var barHeight: CGFloat = 66.0
    public var sliderHeight: CGFloat = 4.0
    public var sideInsetsOnShownState: CGFloat = 16.0
    public var pinDefaultSize: CGFloat = 12.0
    public var pinIncreasedSize: CGFloat = 20.0
    
    public var sliderBackgroundColor: UIColor = .white.withAlphaComponent(0.44)
    public var sliderFillColor: UIColor = .systemBlue
    
    public var previewTimeLabelFont: UIFont = .systemFont(ofSize: 18, weight: .medium)
    public var previewTimeLabelColor: UIColor = .white
    
    public var isRoundedCornersSlider: Bool = true
    public var isEnableVibrate: Bool = true
    
    public init() { }
}
