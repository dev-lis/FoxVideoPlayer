//
//  FVPAssembly.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

protocol FVPAssembler {
    var resolver: FVPResolver { get }
}

final class FVPAssembly: FVPAssembler {
    
    var resolver: FVPResolver {
        serviceLocator.resolver
    }
    
    private let serviceLocator: FVPServiceLocating = FVPServiceLocator()
    
    private var dependency: FVPDependency
    
    init(dependency: FVPDependency) {
        self.dependency = dependency
        assemble()
    }
    
    private func assemble() {
        serviceLocator.register(FVPVideoPlayer.self) { _ in
            if let player = dependency.player {
                return player
            } else {
                let player = FVPVideoPlayerView()
                return player
            }
        }
        
        serviceLocator.register(FVPControls.self) { _ in
            if let controls = dependency.controls {
                return controls
            } else {
                let settings = FVPControlsSettings()
                let controls = FVPControlsView(settings: settings)
                return controls
            }
        }
        
        serviceLocator.register(FVPProgressSlider.self) { _ in
            if let progressSlider = dependency.progressSlider {
                return progressSlider
            } else {
                let settings = FVPProgressBarSliderSettings()
                let progressSlider = FVPProgressSliderControl(settings: settings)
                return progressSlider
            }
        }
        
        serviceLocator.register(FVPProgressBar.self) { resolver in
            if let progressBar = dependency.progressBar {
                return progressBar
            } else {
                var progressSlider: FVPProgressSlider = resolver.resolve()!
                let settings = FVPProgressBarSettings()
                let progressBar = FVPProgressBarView(progressSlider: progressSlider, settings: settings)
                progressSlider.delegate = progressBar
                return progressBar
            }
        }
        
        serviceLocator.register(FVPPlaceholder.self) { _ in
            if let placeholder = dependency.placeholder {
                return placeholder
            } else {
                let settings = FVPPlaceholderSettings()
                let placeholder = FVPPlaceholderView(settings: settings)
                return placeholder
            }
        }
        
        serviceLocator.register(FVPLoader.self) { _ in
            if let loader = dependency.loader {
                return loader
            } else {
                let settings = FVPLoaderSettings()
                let loader = FVPLoaderView(settings: settings)
                return loader
            }
        }
        
        serviceLocator.register(FVPFullScreen.self) { _ in
            if let fullScreen = dependency.fullScreen {
                return fullScreen
            } else {
                let fullScreen = FVPFullScreenViewController()
                return fullScreen
            }
        }
        
        serviceLocator.register(FVPViewController.self) { resolver in
            let videoPlayer = FVPViewController()
            
            if var player: FVPVideoPlayer = resolver.resolve() {
                player.delegate = videoPlayer
                videoPlayer.player = player
            }
            
            if var controls: FVPControls = resolver.resolve() {
                controls.delegate = videoPlayer
                videoPlayer.controls = controls
            }
            
            if var progressBar: FVPProgressBar = resolver.resolve() {
                progressBar.delegate = videoPlayer
                videoPlayer.progressBar = progressBar
            }
            
            if var placeholder: FVPPlaceholder = resolver.resolve() {
                placeholder.delegate = videoPlayer
                videoPlayer.placeholder = placeholder
            }
            
            if let loader: FVPLoader = resolver.resolve() {
                videoPlayer.loader = loader
            }
            
            if var fullScreen: FVPFullScreen = resolver.resolve() {
                fullScreen.delegate = videoPlayer
                videoPlayer.fullScreen = fullScreen
            }
            
            return videoPlayer
        }
    }
}
