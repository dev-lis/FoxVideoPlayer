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
            container.register(FoxVideoPlayerControlsView.self) { _ in
                controls
            }
        } else {
            container.register(FoxVideoPlayerControlsView.self) { resolver in
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
            FoxVideoPlayerViewController()
        }
    }
}
