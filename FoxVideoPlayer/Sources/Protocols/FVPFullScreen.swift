//
//  FVPFullScreen.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.08.2022.
//

import Foundation

public protocol FVPFullScreenDelegate: AnyObject {
    func willHideFullScreen(_ controller: FVPFullScreen)
    func didHideFullScreen(_ controller: FVPFullScreen)
}

public protocol FVPFullScreen {
    
    var delegate: FVPFullScreenDelegate? { get set }
    
    func open(_ playerView: UIView, source: Source)
    func close()
}

public enum Source {
    case button
    case rotate
}
