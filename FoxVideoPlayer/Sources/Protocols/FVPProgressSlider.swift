//
//  FVPProgressSlider.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 08.08.2022.
//

import Foundation

public protocol FVPProgressSliderDelegate: AnyObject {
    func movingOnRaised(_ progressSlider: FVPProgressSlider, isMoving: Bool)
    func movingOnHidden(_ progressSlider: FVPProgressSlider, isMoving: Bool)
    func updateCurrentTime(_ progressSlider: FVPProgressSlider, time: CGFloat)
    func makeImage(_ progressSlider: FVPProgressSlider, for time: CGFloat)
}

public protocol FVPProgressSlider {
    
    var sliderTopInset: CGFloat { get }
    
    var delegate: FVPProgressSliderDelegate? { get set }
    
    func add(to view: UIView)
    func didUpdateTime()
    func setPreviewImage(_ image: UIImage?)
    func setPreviewImageSize(_ size: CGSize)
    func setCurrentTime(_ currentTime: CGFloat, of duration: CGFloat)
    
    func updateLayout()
    func showAnimation()
    func hideAnimation()
}
