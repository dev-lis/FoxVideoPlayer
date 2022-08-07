//
//  FoxVideoPlayerDependency.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public struct FoxVideoPlayerDependency {
    public var controls: FoxVideoPlayerControls?
    public var progressBar: FoxVideoPlayerProgressBarView?
    
    public init(controls: FoxVideoPlayerControls? = nil,
                progressBar: FoxVideoPlayerProgressBarView? = nil) {
        self.controls = controls
        self.progressBar = progressBar
    }
}
