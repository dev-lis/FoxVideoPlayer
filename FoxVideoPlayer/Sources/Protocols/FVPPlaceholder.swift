//
//  FVPPlaceholder.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.08.2022.
//

import Foundation

public protocol FVPPlaceholderDelegate: AnyObject {
    func repeate(_ placeholder: FVPPlaceholder)
}

public protocol FVPPlaceholder {
    var delegate: FVPPlaceholderDelegate? { get set }
    
    func add(to view: UIView)
    func show()
    func hide()
}
