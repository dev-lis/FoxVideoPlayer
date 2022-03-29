//
//  CMTime+Extensions.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import AVFoundation

extension CMTime {
    var timeInterval: TimeInterval? {
        if CMTIME_IS_INVALID(self) || CMTIME_IS_INDEFINITE(self) {
            return nil
        }
        return CMTimeGetSeconds(self)
    }
}
