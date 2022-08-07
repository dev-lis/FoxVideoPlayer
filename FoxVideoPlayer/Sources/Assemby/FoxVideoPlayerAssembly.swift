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
            container.register(FoxVideoPlayerProgressBarView.self) { _ in
                progressBar
            }
        } else {
            container.register(FoxVideoPlayerProgressBarView.self) { resolver in
                FoxVideoPlayerProgressBarView()
            }
        }
        
        container.register(FoxVideoPlayerViewController.self) { resolver in
            let videoPlayer = FoxVideoPlayerViewController()
            
            let player = FoxVideoPlayerView()
            player.delegate = videoPlayer
            videoPlayer.player = player
            
            let controls = resolver.resolve(FoxVideoPlayerControls.self)
            controls?.delegate = videoPlayer
            videoPlayer.controls = controls
            
            return videoPlayer
        }
    }
}
