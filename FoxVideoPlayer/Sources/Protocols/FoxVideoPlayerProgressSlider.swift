//
//  FoxVideoPlayerProgressSlider.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 08.08.2022.
//

import Foundation

public protocol FoxVideoPlayerProgressSliderDelegate: AnyObject {
    func movingOnRaised(_ progressSlider: FoxVideoPlayerProgressSlider, isMoving: Bool)
    func movingOnHidden(_ progressSlider: FoxVideoPlayerProgressSlider, isMoving: Bool)
    func updateCurrentTime(_ progressSlider: FoxVideoPlayerProgressSlider, time: CGFloat)
    func makeImage(_ progressSlider: FoxVideoPlayerProgressSlider, for time: CGFloat)
}

public protocol FoxVideoPlayerProgressSlider {
    var sliderTopInset: CGFloat { get }
    
    var delegate: FoxVideoPlayerProgressSliderDelegate? { get set }
    
    func add(to view: UIView)
    func didUpdateTime()
    func setPreviewImage(_ image: UIImage?)
    func setPreviewImageSize(_ size: CGSize)
    func setCurrentTime(_ currentTime: CGFloat, of duration: CGFloat)
    
    func updateLayout()
    func showAnimation()
    func hideAnimation()
}
