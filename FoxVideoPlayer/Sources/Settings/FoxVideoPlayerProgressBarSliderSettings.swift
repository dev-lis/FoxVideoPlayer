//
//  FoxVideoPlayerProgressBarSliderSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 30.03.2022.
//

import Foundation

public struct FoxVideoPlayerProgressBarSliderSettings {
    let color: Color
    let font: Font
    let size: Size
    let duration: Duration
    let flag: Flag
    
    public init(color: Color = Color(),
                font: Font = Font(),
                size: Size = Size(),
                duration: Duration = Duration(),
                flag: Flag = Flag()) {
        self.color = color
        self.font = font
        self.size = size
        self.duration = duration
        self.flag = flag
    }
}

extension FoxVideoPlayerProgressBarSliderSettings {
    public struct Color {
        let sliderBackground: UIColor
        let sliderFill: UIColor
        let previewTime: UIColor
        
        public init(sliderBackground: UIColor = .white.withAlphaComponent(0.44),
                    sliderFill: UIColor = .systemBlue,
                    previewTime: UIColor = .white) {
            self.sliderBackground = sliderBackground
            self.sliderFill = sliderFill
            self.previewTime = previewTime
        }
    }
}

extension FoxVideoPlayerProgressBarSliderSettings {
    public struct Font {
        let previewTime: UIFont
        
        public init(previewTime: UIFont = .systemFont(ofSize: 18, weight: .medium)) {
            self.previewTime = previewTime
        }
    }
}

extension FoxVideoPlayerProgressBarSliderSettings {
    public struct Size {
        let sliderHeight: CGFloat
        let sideInsetsOnShownState: CGFloat
        let pinDefaultSize: CGFloat
        let pinIncreasedSize: CGFloat
        let previewLabelBottomInset: CGFloat
        let previewImageBottomInset: CGFloat
        
        public init(sliderHeight: CGFloat = 4.0,
                    sideInsetsOnShownState: CGFloat = 16.0,
                    pinDefaultSize: CGFloat = 12.0,
                    pinIncreasedSize: CGFloat = 20.0,
                    previewLabelBottomInset: CGFloat = 8.0,
                    previewImageBottomInset: CGFloat = 8.0) {
            self.sliderHeight = sliderHeight
            self.sideInsetsOnShownState = sideInsetsOnShownState
            self.pinDefaultSize = pinDefaultSize
            self.pinIncreasedSize = pinIncreasedSize
            self.previewLabelBottomInset = previewLabelBottomInset
            self.previewImageBottomInset = previewImageBottomInset
        }
    }
}

extension FoxVideoPlayerProgressBarSliderSettings {
    public struct Duration {
        let animation: TimeInterval
        
        public init(animation: TimeInterval = 0.2) {
            self.animation = animation
        }
    }
}

extension FoxVideoPlayerProgressBarSliderSettings {
    public struct Flag {
        let isRoundedCornersSlider: Bool
        let isEnableVibrate: Bool
        
        public init(isRoundedCornersSlider: Bool = true,
                    isEnableVibrate: Bool = true) {
            self.isRoundedCornersSlider = isRoundedCornersSlider
            self.isEnableVibrate = isEnableVibrate
        }
    }
}
