//
//  FVPVideoPlayerView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit
import AVFoundation

public class FVPVideoPlayerView: UIView {
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    public var player: AVPlayer? {
        get { playerLayer?.player }
        set { playerLayer?.player = newValue }
    }

    public var playerLayer: AVPlayerLayer? {
        layer as? AVPlayerLayer
    }
    
    public var startPlaying: (() -> Void)?

    private var currentAsset: AVAsset?

    private var playerItemContext = 0
    private var playerItem: AVPlayerItem?
    private var playerTimeObserver: Any?

    public weak var delegate: FVPVideoPlayerDelegate?

    private var rate: Float

    public init(rate: Float = 1.0) {
        self.rate = rate
        super.init(frame: .zero)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removePlayerObservers()
    }
    
    private func setupBackgroundMode() {
        if #available(iOS 15.0, *) {
            self.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
    }

    private func setupPlayerItem(with asset: AVAsset, startTime: TimeInterval? = nil, rate: Float? = nil) {
        playerItem = AVPlayerItem(asset: asset)
        currentAsset = asset
        
        addPlayerObservers()
        
        player = AVPlayer(playerItem: self.playerItem!)
        setupBackgroundMode()
        
        if let startTime = startTime {
            setTime(startTime)
        }

        if let rate = rate {
            setRate(rate)
        }
    }
    
    private func setTime(cmTime: CMTime) {
        let duration = player?.currentItem?.asset.duration.seconds ?? 0
        let isCompleted = cmTime.seconds >= duration
        
        let newTime = isCompleted
        ? CMTimeMakeWithSeconds(duration, preferredTimescale: Int32(NSEC_PER_SEC))
        : cmTime
        
        DispatchQueue.main.async {
            self.player?.currentItem?.seek(
                to: newTime,
                toleranceBefore: .zero,
                toleranceAfter: .indefinite) { [weak self] _ in
                    guard let self = self else { return }
                    self.delegate?.didUpdateTime(self, isCompleted: isCompleted)
            }
        }
    }

    private func addPlayerObservers() {
        playerItem?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.old, .new],
            context: &playerItemContext
        )

        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.playerDidFinishPlaying),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: self.player?.currentItem
            )

            let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))

            self.playerTimeObserver = self.player?.addPeriodicTimeObserver(forInterval: interval,
                                                                           queue: DispatchQueue.main,
                                                                           using: { [weak self] cmTime in
                guard
                    let self = self,
                    let time = cmTime.timeInterval,
                    let duration = self.player?.currentItem?.asset.duration.seconds
                else { return }
                self.delegate?.updateTime(self, time: time, duration: duration)
            })
        }
    }

    private func removePlayerObservers() {
        guard let playerTimeObserver = self.playerTimeObserver else { return }
        self.player?.removeTimeObserver(playerTimeObserver)
        self.playerTimeObserver = nil
    }

    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if let error = playerItem?.error as? NSError, let keyPath = keyPath {
            print("Fox Video Player for keyPath: \"\(keyPath.capitalized)\" error: \"\(error.localizedDescription.capitalized)\" with code: \(error.code)")
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            if let statusNumber = change?[.newKey] as? NSNumber,
               let status = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
                playerItemStatusDidChange(status: status)
            } else {
                playerItemStatusDidChange(status: .unknown)
            }
        } else if keyPath == #keyPath(AVPlayer.rate) {
            if let rate = change?[.newKey] as? Float {
                self.playerRateDidChange(rate: rate)
            }
        }
    }

    // MARK: Observation Helpers

    private func playerItemStatusDidChange(status: AVPlayerItem.Status) {
        let state: FVPVideoState
        switch status {
        case .readyToPlay:
            state = .ready
        default:
            state = .failed
        }
        print("Fox Player state change to: \(state)")
        delegate?.updatePlayerState(self, state: state)
    }

    private func playerRateDidChange(rate: Float) {
        let state: FVPPlaybackState
        if rate == 0 {
            state = .pause
        } else if let currentTime = player?.currentItem?.currentTime().seconds,
            let duration = player?.currentItem?.asset.duration.seconds,
            currentTime == duration {
            state = .completed
        } else {
            state = .play
        }
        print("Fox Playback state change to: \(state)")
        delegate?.updatePlaybackState(self, state: state)
    }

    @objc private func playerDidFinishPlaying() {
        let state: FVPPlaybackState = .completed
        print("Fox Playback state change to: \(state)")
        delegate?.updatePlaybackState(self, state: state)
    }
}

// MARK: FVPVideoPlayer

extension FVPVideoPlayerView: FVPVideoPlayer {
    public func add(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public func setup(with asset: FVPAsset) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.backgroundColor = .black
            self.setupPlayerItem(
                with: AVAsset(url: asset.url),
                startTime: asset.startTime,
                rate: asset.rate
            )
        }
    }

    public func play() {
        DispatchQueue.main.async {
            self.player?.play()
            self.player?.rate = self.rate

            self.startPlaying?()
            print("Fox Playback state change to: \(FVPPlaybackState.play)")
        }
    }

    public func pause() {
        player?.pause()
        print("Fox Playback state change to: \(FVPPlaybackState.pause)")
    }
    
    public func relplay() {
        setTime(0)
        play()
    }

    public func seekInterval(_ interval: TimeInterval) {
        guard
            let currentTime = player?.currentItem?.currentTime().seconds,
            let duration = player?.currentItem?.asset.duration.seconds,
            let currentCMTime = player?.currentTime()
        else { return }
        let inset = currentTime + interval < duration
            ? interval
            : duration - TimeInterval(Int(currentTime))
        let cmTime = currentCMTime + CMTimeMakeWithSeconds(inset, preferredTimescale: Int32(NSEC_PER_SEC))
        
        delegate?.willUpdateTime(self, isCompleted: currentTime + inset >= duration, from: .controls)

        setTime(cmTime: cmTime)
    }
    
    public func setTime(_ time: TimeInterval) {
        let duration = player?.currentItem?.asset.duration.seconds ?? 0
        delegate?.willUpdateTime(self, isCompleted: time >= duration, from: .progressBar)
        
        let cmTime = CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC))
        setTime(cmTime: cmTime)
    }

    public func getCurrentTime() -> TimeInterval {
        let currentTime = player?.currentItem?.currentTime().seconds ?? 0
        return currentTime
    }

    public func getDurationTime() -> TimeInterval {
        let duration = player?.currentItem?.asset.duration.seconds ?? 0
        return duration
    }

    public func setRate(_ rate: Float) {
        DispatchQueue.main.async {
            self.rate = rate

            guard self.player?.rate != 0 else { return }
            self.player?.rate = rate
        }
    }
    
    public func updateRateAfterBackground() {
        playerRateDidChange(rate: player?.rate ?? 0)
    }
    
    public func renderPreviewImage(for time: TimeInterval) {
        DispatchQueue.global(qos: .userInteractive).async {
            let cmTime = CMTime(seconds: time, preferredTimescale: 1000000)
            guard let asset = self.currentAsset else { return }
            do {
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                let videoFrameCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
                let image = UIImage(cgImage: videoFrameCGImage)
                DispatchQueue.main.async {
                    self.delegate?.updatePreviewImage(self, image: image)
                }
            } catch {
                print("Fox Video Player generate preview image error: \(error.localizedDescription)")
                self.delegate?.updatePreviewImage(self, image: nil)
            }
        }
    }
    
    public func previewImageSize() -> CGSize {
        let width = frame.height * 16 / 9
        return CGSize(width: width / 4, height: frame.height / 4)
    }
}
