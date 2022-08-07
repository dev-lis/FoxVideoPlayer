//
//  FoxVideoPlayerDependency.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public struct FoxVideoPlayerDependency {
    let player: FoxVideoPlayer?
    let controls: FoxVideoPlayerControls?
    let progressBar: FoxVideoPlayerProgressBarView?
    
    public init(player: FoxVideoPlayer? = nil,
                controls: FoxVideoPlayerControls? = nil,
                progressBar: FoxVideoPlayerProgressBarView? = nil) {
        self.player = player
        self.controls = controls
        self.progressBar = progressBar
    }
}
