//
//  FoxStates.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import Foundation

public enum FoxVideoPlayerState {
    case ready
    case failed
}

public enum FoxVideoPlaybackState {
    case pause
    case play
    case completed
}

public enum FoxProgressBarState {
    case visible
    case hidden
}

public enum FoxScreenMode {
    case `default`
    case fullScreen
}

public enum FoxUpdateTimeFrom {
    case controls
    case progressBar
}
