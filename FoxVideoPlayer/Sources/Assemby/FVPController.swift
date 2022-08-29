//
//  FVPController.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public class FVPController {
    
    private var resolver: FVPResolver {
        assembler.resolver
    }
    
    private let assembler: FVPAssembler

    public init(dependency: FVPDependency) {
        self.assembler = FVPAssembly(dependency: dependency)
    }
    
    public func getVideoPlayer() -> FVPViewController {
        let controller: FVPViewController = resolver.resolve()!
        return controller
    }
}
