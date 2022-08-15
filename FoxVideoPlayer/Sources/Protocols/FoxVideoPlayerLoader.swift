//
//  FoxVideoPlayerLoader.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 14.08.2022.
//

import Foundation

public protocol FoxVideoPlayerLoader {
    
    func add(to view: UIView)
    func start()
    func stop()
}
