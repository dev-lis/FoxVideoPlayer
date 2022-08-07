//
//  FoxVideoPlayer.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public protocol FoxVideoPlayerDelegate: AnyObject {
    func updatePlayerState(_ player: FoxVideoPlayer, state: FoxVideoPlayerState)
    func updatePlaybackState(_ player: FoxVideoPlayer, state: FoxVideoPlaybackState)
    func updateTime(_ player: FoxVideoPlayer, time: TimeInterval, duration: TimeInterval)
    func willUpdateTime(_ player: FoxVideoPlayer, isCompleted: Bool, from: FoxUpdateTimeFrom)
    func didUpdateTime(_ player: FoxVideoPlayer, isCompleted: Bool)
    func updatePreviewImage(_ player: FoxVideoPlayer, image: UIImage?)
}

public protocol FoxVideoPlayer {
    
    var delegate: FoxVideoPlayerDelegate? { get set }
    
    func add(to view: UIView)
    func setup(with asset: FoxVideoPlayerAsset)
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

extension FoxVideoPlayer {
    func renderPreviewImage(for time: TimeInterval) {}
    func previewImageSize() -> CGSize { .zero }
}
