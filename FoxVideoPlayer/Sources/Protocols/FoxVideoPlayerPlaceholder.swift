//
//  FoxVideoPlayerPlaceholder.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.08.2022.
//

import Foundation

public protocol FoxVideoPlayerPlaceholderDelegate: AnyObject {
    func repeate(_ placeholder: FoxVideoPlayerPlaceholder)
}

public protocol FoxVideoPlayerPlaceholder {
    var delegate: FoxVideoPlayerPlaceholderDelegate? { get set }
    
    func add(to view: UIView)
    func show()
    func hide()
}
