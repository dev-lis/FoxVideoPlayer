//
//  FVPLoader.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 14.08.2022.
//

import Foundation

public protocol FVPLoader {
    
    func add(to view: UIView)
    func start()
    func stop()
}
