//
//  FVPControls.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public protocol FVPControlsDelegate: AnyObject {
    func didTapPlay(_ controls: FVPControls, isPlay: Bool)
    func didTapReplay(_ controls: FVPControls)
    func didTapSeek(_ controls: FVPControls, interval: TimeInterval)
    func updateVisibleControls(_ controls: FVPControls, isVisible: Bool)
}

public protocol FVPControls {
    
    var delegate: FVPControlsDelegate? { get set }
    
    func add(to view: UIView)
    func setPlayerState(_ state: FVPVideoState)
    func setPlaybackState(_ state: FVPPlaybackState)
    func setVisibleControls(_ isVisible: Bool)
    func setDarkenBackground(_ isDraken: Bool)
    func updateStateForFullScreen(isPause: Bool)
    func updatePlayPauseButton(isPlaying: Bool)
    func loading(_ isLoading: Bool)
    func resetVisibleControls()
}
