//
//  FoxVideoPlayerAsset.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import Foundation

public struct FoxVideoPlayerAsset {
    let url: URL
    let startTime: TimeInterval?
    let rate: Float?

    public init(url: URL,
                startTime: TimeInterval? = nil,
                rate: Float? = nil) {
        self.url = url
        self.startTime = startTime
        self.rate = rate
    }
}
