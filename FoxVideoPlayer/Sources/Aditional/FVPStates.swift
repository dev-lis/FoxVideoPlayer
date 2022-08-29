//
//  FVPStates.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import Foundation

public enum FVPVideoState {
    case ready
    case failed
}

public enum FVPPlaybackState {
    case pause
    case play
    case completed
}

public enum FVPProgressBarState {
    case visible
    case hidden
}

public enum FVPScreenMode {
    case `default`
    case fullScreen
}

public enum FVPUpdateTimeFrom {
    case controls
    case progressBar
}
