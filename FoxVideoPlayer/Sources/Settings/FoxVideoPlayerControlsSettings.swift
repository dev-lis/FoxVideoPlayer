//
//  FoxVideoPlayerControlsSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 08.08.2022.
//

import UIKit

public struct FoxVideoPlayerControlsSettings {
    
    let darkenColor: UIColor
    let images: Images
    let size: Size
    
    let animateDuration: TimeInterval
    let autoHideControlsDelay: TimeInterval
    
    let isEnableSeekOnDoubleTap: Bool
    
    public init(darkenColor: UIColor = .black.withAlphaComponent(0.46),
                images: Images = Images(),
                size: Size = Size(),
                animateDuration: TimeInterval = 0.2,
                autoHideControlsDelay: TimeInterval = 3.0,
                isEnableSeekOnDoubleTap: Bool = true) {
        self.darkenColor = darkenColor
        self.images = images
        self.size = size
        self.animateDuration = animateDuration
        self.autoHideControlsDelay = autoHideControlsDelay
        self.isEnableSeekOnDoubleTap = isEnableSeekOnDoubleTap
    }
}

extension FoxVideoPlayerControlsSettings {
    public struct Images {
        let startPlay: UIImage?
        let replay: UIImage?
        let play: UIImage?
        let pause: UIImage?
        let backward: UIImage?
        let forward: UIImage?
        
        public init(startPlay: UIImage? = nil,
                    replay: UIImage? = nil,
                    play: UIImage? = nil,
                    pause: UIImage? = nil,
                    backward: UIImage? = nil,
                    forward: UIImage? = nil) {
            if let startPlay = startPlay {
                self.startPlay = startPlay
            } else {
                let configuration = UIImage.SymbolConfiguration(pointSize: 50)
                self.startPlay = UIImage(systemName: "play.fill", withConfiguration: configuration)
            }
            if let replay = replay {
                self.replay = replay
            } else {
                let configuration = UIImage.SymbolConfiguration(pointSize: 50)
                self.replay = UIImage(systemName: "gobackward", withConfiguration: configuration)
            }
            if let play = play {
                self.play = play
            } else {
                let configuration = UIImage.SymbolConfiguration(pointSize: 40)
                self.play = UIImage(systemName: "play.fill", withConfiguration: configuration)
            }
            if let pause = pause {
                self.pause = pause
            } else {
                let configuration = UIImage.SymbolConfiguration(pointSize: 40)
                self.pause = UIImage(systemName: "pause.fill", withConfiguration: configuration)
            }
            if let backward = backward {
                self.backward = backward
            } else {
                let configuration = UIImage.SymbolConfiguration(pointSize: 30)
                self.backward = UIImage(systemName: "gobackward", withConfiguration: configuration)
            }
            if let forward = forward {
                self.forward = forward
            } else {
                let configuration = UIImage.SymbolConfiguration(pointSize: 30)
                self.forward = UIImage(systemName: "goforward", withConfiguration: configuration)
            }
        }
    }
}

extension FoxVideoPlayerControlsSettings {
    public struct Size {
        let centerAreaWidth: CGFloat
        let startPlayReplayCenterYInset: CGFloat
        let playPauseCenterYInset: CGFloat
        let seekButtonsCenterYInset: CGFloat
        let seekButtonsCenterXInset: CGFloat
        
        let playPauseButtonSize: CGFloat
        let startPlayReplayButtonSize: CGFloat
        let seekButtonsSize: CGFloat
        
        public init(centerAreaWidth: CGFloat = 80,
                    startPlayReplayCenterYInset: CGFloat = 8,
                    playPauseCenterYInset: CGFloat = -16,
                    seekButtonsCenterYInset: CGFloat = -16,
                    seekButtonsCenterXInset: CGFloat = 40,
                    playPauseButtonSize: CGFloat = 40,
                    startPlayReplayButtonSize: CGFloat = 60,
                    seekButtonsSize: CGFloat = 40) {
            self.centerAreaWidth = centerAreaWidth
            self.startPlayReplayCenterYInset = startPlayReplayCenterYInset
            self.playPauseCenterYInset = playPauseCenterYInset
            self.seekButtonsCenterYInset = seekButtonsCenterYInset
            self.seekButtonsCenterXInset = seekButtonsCenterXInset
            self.playPauseButtonSize = playPauseButtonSize
            self.startPlayReplayButtonSize = startPlayReplayButtonSize
            self.seekButtonsSize = seekButtonsSize
        }
    }
}
