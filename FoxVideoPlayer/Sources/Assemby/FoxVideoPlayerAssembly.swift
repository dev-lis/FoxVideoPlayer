//
//  FoxVideoPlayerAssembly.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

protocol FVPAssembler {
    var resolver: FVPResolver { get }
}

final class FoxVideoPlayerAssembly: FVPAssembler {
    
    var resolver: FVPResolver {
        serviceLocator.resolver
    }
    
    private let serviceLocator: FVPServiceLocating = FVPServiceLocator()
    
    private var dependency: FoxVideoPlayerDependency
    
    init(dependency: FoxVideoPlayerDependency) {
        self.dependency = dependency
        assemble()
    }
    
    private func assemble() {
        serviceLocator.register(FoxVideoPlayer.self) { _ in
            if let player = dependency.player {
                return player
            } else {
                let player = FoxVideoPlayerView()
                return player
            }
        }
        
        serviceLocator.register(FoxVideoPlayerControls.self) { _ in
            if let controls = dependency.controls {
                return controls
            } else {
                let settings = FoxVideoPlayerControlsSettings()
                let controls = FoxVideoPlayerControlsView(settings: settings)
                return controls
            }
        }
        
        serviceLocator.register(FoxVideoPlayerProgressSlider.self) { _ in
            if let progressSlider = dependency.progressSlider {
                return progressSlider
            } else {
                let settings = FoxVideoPlayerProgressBarSliderSettings()
                let progressSlider = FoxVideoPlayerProgressSliderControl(settings: settings)
                return progressSlider
            }
        }
        
        serviceLocator.register(FoxVideoPlayerProgressBar.self) { resolver in
            if let progressBar = dependency.progressBar {
                return progressBar
            } else {
                var progressSlider: FoxVideoPlayerProgressSlider = resolver.resolve()!
                let settings = FoxVideoPlayerProgressBarSettings()
                let progressBar = FoxVideoPlayerProgressBarView(progressSlider: progressSlider, settings: settings)
                progressSlider.delegate = progressBar
                return progressBar
            }
        }
        
        serviceLocator.register(FoxVideoPlayerPlaceholder.self) { _ in
            if let placeholder = dependency.placeholder {
                return placeholder
            } else {
                let settings = FoxVideoPlayerPlaceholderSettings()
                let placeholder = FoxVideoPlayerPlaceholderView(settings: settings)
                return placeholder
            }
        }
        
        serviceLocator.register(FoxVideoPlayerLoader.self) { _ in
            if let loader = dependency.loader {
                return loader
            } else {
                let settings = FoxVideoPlayerLoaderSettings()
                let loader = FoxVideoPlayerLoaderView(settings: settings)
                return loader
            }
        }
        
        serviceLocator.register(FoxVideoPlayerFullScreen.self) { _ in
            if let fullScreen = dependency.fullScreen {
                return fullScreen
            } else {
                let fullScreen = FoxVideoPlayerFullScreenViewController()
                return fullScreen
            }
        }
        
        serviceLocator.register(FoxVideoPlayerViewController.self) { resolver in
            let videoPlayer = FoxVideoPlayerViewController()
            
            if var player: FoxVideoPlayer = resolver.resolve() {
                player.delegate = videoPlayer
                videoPlayer.player = player
            }
            
            if var controls: FoxVideoPlayerControls = resolver.resolve() {
                controls.delegate = videoPlayer
                videoPlayer.controls = controls
            }
            
            if var progressBar: FoxVideoPlayerProgressBar = resolver.resolve() {
                progressBar.delegate = videoPlayer
                videoPlayer.progressBar = progressBar
            }
            
            if var placeholder: FoxVideoPlayerPlaceholder = resolver.resolve() {
                placeholder.delegate = videoPlayer
                videoPlayer.placeholder = placeholder
            }
            
            if let loader: FoxVideoPlayerLoader = resolver.resolve() {
                videoPlayer.loader = loader
            }
            
            if var fullScreen: FoxVideoPlayerFullScreen = resolver.resolve() {
                fullScreen.delegate = videoPlayer
                videoPlayer.fullScreen = fullScreen
            }
            
            return videoPlayer
        }
    }
}
