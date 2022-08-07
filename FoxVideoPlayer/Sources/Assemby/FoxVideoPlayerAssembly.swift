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
            container.register(FoxVideoPlayer.self) { resolver in
                FoxVideoPlayerView()
            }
        }
        
        if let controls = dependency.controls {
            container.register(FoxVideoPlayerControls.self) { _ in
                controls
            }
        } else {
            container.register(FoxVideoPlayerControls.self) { resolver in
                FoxVideoPlayerControlsView()
            }
        }
        
        if let progressBar = dependency.progressBar {
            container.register(FoxVideoPlayerProgressBar.self) { _ in
                progressBar
            }
        } else {
            container.register(FoxVideoPlayerProgressBar.self) { resolver in
                let settings = FoxVideoPlayerProgressBarSettings()
                return FoxVideoPlayerProgressBarView(settings: settings)
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
