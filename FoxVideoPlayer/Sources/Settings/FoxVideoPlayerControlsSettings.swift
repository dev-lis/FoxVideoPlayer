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
    let insets: Insets
    
    let animateDuration: TimeInterval
    let autoHideControlsDelay: TimeInterval
    
    let isEnableSeekOnDoubleTap: Bool
    
    public init(darkenColor: UIColor = .black.withAlphaComponent(0.46),
                images: Images = Images(),
                insets: Insets = Insets(),
                animateDuration: TimeInterval = 0.2,
                autoHideControlsDelay: TimeInterval = 3.0,
                isEnableSeekOnDoubleTap: Bool = true) {
        self.darkenColor = darkenColor
        self.images = images
        self.insets = insets
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
    public struct Insets {
        let playPauseAreaWidth: CGFloat
        let playPauseCenterY: CGFloat
        let startPlayReplayCenterY: CGFloat
        let backwardForwardCenterY: CGFloat
        let backwardForwardCenterX: CGFloat
        
        public init(playPauseAreaWidth: CGFloat = 80,
                    playPauseCenterY: CGFloat = -16,
                    startPlayReplayCenterY: CGFloat = 8,
                    backwardForwardCenterY: CGFloat = -16,
                    backwardForwardCenterX: CGFloat = 40) {
            self.playPauseAreaWidth = playPauseAreaWidth
            self.playPauseCenterY = playPauseCenterY
            self.startPlayReplayCenterY = startPlayReplayCenterY
            self.backwardForwardCenterY = backwardForwardCenterY
            self.backwardForwardCenterX = backwardForwardCenterX
        }
    }
}