//
//  FoxVideoPlayerFullScreen.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.08.2022.
//

import Foundation

public protocol FoxVideoPlayerFullScreenViewControllerDelegate: AnyObject {
    func willHideFullScreen(_ controller: FoxVideoPlayerFullScreenViewController)
    func didHideFullScreen(_ controller: FoxVideoPlayerFullScreenViewController)
}

public protocol FoxVideoPlayerFullScreen {
    
    var delegate: FoxVideoPlayerFullScreenViewControllerDelegate? { get set }
    
    func open(_ playerView: UIView, source: Source)
    func close()
}

public enum Source {
    case button
    case rotate
}
