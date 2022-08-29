//
//  FVPServiceLocator.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 30.08.2022.
//

import Foundation

protocol FVPServiceLocating {
    var resolver: FVPResolver { get }
    
    func register<T>(_ type: T.Type, dependency: (FVPResolver) -> T)
}

protocol FVPResolver {
    func resolve<T>() -> T?
}

final class FVPServiceLocator: FVPServiceLocating {
    
    var resolver: FVPResolver { self }
    
    private var dependencies: [String: Any] = [:]
    
    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
    
    func register<T>(_ type: T.Type, dependency: (FVPResolver) -> T) {
        let key = typeName(type)
        dependencies[key] = dependency(self)
    }
}

extension FVPServiceLocator: FVPResolver {
    func resolve<T>() -> T? {
        let key = typeName(T.self)
        return dependencies[key] as? T
    }
}
