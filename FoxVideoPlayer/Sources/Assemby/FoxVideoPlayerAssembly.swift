//
//  FoxVideoPlayerAssembly.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Swinject

prefix operator <?
prefix func <? <Dependency>(_ resolver: Resolver) -> Dependency? {
    resolver.resolve(Dependency.self)
}

prefix operator <~
prefix func <~ <Dependency>(_ resolver: Resolver) -> Dependency {
    resolver.resolve(Dependency.self)!
}

final class FoxVideoPlayerAssembly: Assembly {
    
    private var dependency: FoxVideoPlayerDependency
    
    init(dependency: FoxVideoPlayerDependency) {
        self.dependency = dependency
    }
    
    func assemble(container: Container) {
        
        if let player = dependency.player {
            container.register(FoxVideoPlayer.self) { _ in
                player
            }
        } else {
            container.register(FoxVideoPlayer.self) { _ in
                FoxVideoPlayerView()
            }
        }
        
        if let controls = dependency.controls {
            container.register(FoxVideoPlayerControls.self) { _ in
                controls
            }
        } else {
            container.register(FoxVideoPlayerControls.self) { _ in
                FoxVideoPlayerControlsView()
            }
        }
        
        if let progressBar = dependency.progressBar {
            container.register(FoxVideoPlayerProgressBar.self) { _ in
                progressBar
            }
        } else {
            container.register(FoxVideoPlayerProgressBar.self) { resolver in
                var progressSlider = resolver.resolve(FoxVideoPlayerProgressSlider.self)!
                let settings = FoxVideoPlayerProgressBarSettings()
                let progressBar = FoxVideoPlayerProgressBarView(progressSlider: progressSlider, settings: settings)
                progressSlider.delegate = progressBar
                return progressBar
            }
        }
        
        if let progressSlider = dependency.progressSlider {
            container.register(FoxVideoPlayerProgressSlider.self) { _ in
                progressSlider
            }
        } else {
            container.register(FoxVideoPlayerProgressSlider.self) { _ in
                FoxVideoPlayerProgressSliderControl()
            }
        }
        
        container.register(FoxVideoPlayerViewController.self) { resolver in
            let videoPlayer = FoxVideoPlayerViewController()
            
            var player = resolver.resolve(FoxVideoPlayer.self)
            player?.delegate = videoPlayer
            videoPlayer.player = player
            
            var controls = resolver.resolve(FoxVideoPlayerControls.self)
            controls?.delegate = videoPlayer
            videoPlayer.controls = controls
            
            var progressBar = resolver.resolve(FoxVideoPlayerProgressBar.self)
            progressBar?.delegate = videoPlayer
            videoPlayer.progressBar = progressBar
            
            return videoPlayer
        }
    }
}
