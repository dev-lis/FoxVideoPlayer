//
//  FoxVideoPlayerControls.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public protocol FoxVideoPlayerControlsViewDelegate: AnyObject {
    func didTapPlay(_ controls: FoxVideoPlayerControlsView, isPlay: Bool)
    func didTapReplay(_ controls: FoxVideoPlayerControlsView)
    func didTapSeek(_ controls: FoxVideoPlayerControlsView, interval: TimeInterval)
    func updateVisibleControls(_ controls: FoxVideoPlayerControlsView, isVisible: Bool)
}

public protocol FoxVideoPlayerControls: AnyObject {
    
    var delegate: FoxVideoPlayerControlsViewDelegate? { get set }
    
    func add(to view: UIView)
    func setPlayerState(_ state: FoxVideoPlayerState)
    func setPlaybackState(_ state: FoxVideoPlaybackState)
    func setVisibleControls(_ isVisible: Bool)
    func setDarkenBackground(_ isDraken: Bool)
    func updateStateForFullScreen(isPause: Bool)
    func updatePlayPauseButton(isPlaying: Bool)
    func loading(_ isLoading: Bool)
    func resetVisibleControls()
}
