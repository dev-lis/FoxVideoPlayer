//
//  FVPDependency.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public struct FVPDependency {
    let player: FVPVideoPlayer?
    let controls: FVPControls?
    let progressBar: FVPProgressBarView?
    let progressBarSettings: FVPProgressBarSettings?
    let progressSlider: FVPProgressSlider?
    let placeholder: FVPPlaceholder?
    let loader: FVPLoader?
    let fullScreen: FVPFullScreen?
    
    public init(player: FVPVideoPlayer? = nil,
                controls: FVPControls? = nil,
                progressBar: FVPProgressBarView? = nil,
                progressBarSettings: FVPProgressBarSettings? = nil,
                progressSlider: FVPProgressSlider? = nil,
                placeholder: FVPPlaceholder? = nil,
                loader: FVPLoader? = nil,
                fullScreen: FVPFullScreen? = nil) {
        self.player = player
        self.controls = controls
        self.progressBar = progressBar
        self.progressBarSettings = progressBarSettings
        self.progressSlider = progressSlider
        self.placeholder = placeholder
        self.loader = loader
        self.fullScreen = fullScreen
    }
}
