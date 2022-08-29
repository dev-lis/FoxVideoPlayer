//
//  FVPProgressBar.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 07.08.2022.
//

import Foundation

public protocol FVPProgressBarDelegate: AnyObject {
    func setTime(_ progressBar: FVPProgressBar, time: TimeInterval)
    func didBeginMovingPin(_ progressBar: FVPProgressBar, state: FVPProgressBarState)
    func didEndMovingPin(_ progressBar: FVPProgressBar, state: FVPProgressBarState)
    func didTapChangeScreenMode(_ progressBar: FVPProgressBar)
    func renderImage(_ progressBar: FVPProgressBar, time: TimeInterval)
}

public protocol FVPProgressBar {
    
    var delegate: FVPProgressBarDelegate? { get set }
    
    var isVisible: Bool { get }
    
    func add(to view: UIView)
    func setHidden(_ isHidden: Bool)
    func setTime(_ time: TimeInterval, duration: TimeInterval)
    func didUpdateTime()
    func updateScreenMode(_ mode: FVPScreenMode)
    func setPreviewImage(_ image: UIImage?)
    func setPreviewImageSize(_ size: CGSize)
    func show()
    func hide()
    func updateFullScreenButton()
}
