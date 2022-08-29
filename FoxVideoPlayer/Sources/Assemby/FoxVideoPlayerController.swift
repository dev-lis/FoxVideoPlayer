//
//  FoxVideoPlayerController.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public class FoxVideoPlayerController {
    
    private var resolver: FVPResolver {
        assembler.resolver
    }
    
    private let assembler: FVPAssembler

    public init(dependency: FoxVideoPlayerDependency) {
        self.assembler = FoxVideoPlayerAssembly(dependency: dependency)
    }
    
    public func getVideoPlayer() -> FoxVideoPlayerViewController {
        let controller: FoxVideoPlayerViewController = resolver.resolve()!
        return controller
    }
}
