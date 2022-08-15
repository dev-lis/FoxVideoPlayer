//
//  FoxVideoPlayerProgressBar.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public protocol FoxVideoPlayerProgressBarDelegate: AnyObject {
    func setTime(_ progressBar: FoxVideoPlayerProgressBar, time: TimeInterval)
    func didBeginMovingPin(_ progressBar: FoxVideoPlayerProgressBar, state: FoxProgressBarState)
    func didEndMovingPin(_ progressBar: FoxVideoPlayerProgressBar, state: FoxProgressBarState)
    func didTapChangeScreenMode(_ progressBar: FoxVideoPlayerProgressBar)
    func renderImage(_ progressBar: FoxVideoPlayerProgressBar, time: TimeInterval)
}

public protocol FoxVideoPlayerProgressBar {
    
    var delegate: FoxVideoPlayerProgressBarDelegate? { get set }
    
    var isVisible: Bool { get }
    
    func add(to view: UIView)
    func setHidden(_ isHidden: Bool)
    func setTime(_ time: TimeInterval, duration: TimeInterval)
    func didUpdateTime()
    func updateScreenMode(_ mode: FoxScreenMode)
    func setPreviewImage(_ image: UIImage?)
    func setPreviewImageSize(_ size: CGSize)
    func show()
    func hide()
    func updateFullScreenButton()
}