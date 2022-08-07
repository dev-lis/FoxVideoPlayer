//
//  FoxVideoPlayerController.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Swinject

public class FoxVideoPlayerController {
    
    private var resolver: Resolver {
        assembler.resolver
    }
    
    private let assembler: Assembler

    public init(dependency: FoxVideoPlayerDependency) {
        let assembly = FoxVideoPlayerAssembly(dependency: dependency)
        assembler = Assembler([assembly])
    }
    
    public func getVideoPlayer() -> FoxVideoPlayerViewController {
        resolver.resolve(FoxVideoPlayerViewController.self)!
    }
}
