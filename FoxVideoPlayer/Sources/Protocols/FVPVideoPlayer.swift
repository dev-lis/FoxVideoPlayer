//
//  FVPVideoPlayer.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public protocol FVPVideoPlayerDelegate: AnyObject {
    func updatePlayerState(_ player: FVPVideoPlayer, state: FVPVideoState)
    func updatePlaybackState(_ player: FVPVideoPlayer, state: FVPPlaybackState)
    func updateTime(_ player: FVPVideoPlayer, time: TimeInterval, duration: TimeInterval)
    func willUpdateTime(_ player: FVPVideoPlayer, isCompleted: Bool, from: FVPUpdateTimeFrom)
    func didUpdateTime(_ player: FVPVideoPlayer, isCompleted: Bool)
    func updatePreviewImage(_ player: FVPVideoPlayer, image: UIImage?)
}

public protocol FVPVideoPlayer {
    
    var delegate: FVPVideoPlayerDelegate? { get set }
    
    func add(to view: UIView)
    func setup(with asset: FVPAsset)
    func play()
    func pause()
    func relplay()
    func seekInterval(_ interval: TimeInterval)
    func setTime(_ time: TimeInterval)
    func getCurrentTime() -> TimeInterval
    func getDurationTime() -> TimeInterval
    func setRate(_ rate: Float)
    func updateRateAfterBackground()
    func renderPreviewImage(for time: TimeInterval)
    func previewImageSize() -> CGSize
}

extension FVPVideoPlayer {
    func renderPreviewImage(for time: TimeInterval) {}
    func previewImageSize() -> CGSize { .zero }
}
