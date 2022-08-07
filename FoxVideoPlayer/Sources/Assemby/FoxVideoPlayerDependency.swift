//
//  FoxVideoPlayerDependency.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public struct FoxVideoPlayerDependency {
    public var controls: FoxVideoPlayerControlsView?
    public var progressBar: FoxVideoPlayerProgressBarView?
    
    public init(controls: FoxVideoPlayerControlsView? = nil,
                progressBar: FoxVideoPlayerProgressBarView? = nil) {
        self.controls = controls
        self.progressBar = progressBar
    }
}
