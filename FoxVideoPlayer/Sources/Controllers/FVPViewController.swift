//
//  FVPViewController.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.03.2022.
//

import UIKit

public class FVPViewController: UIViewController {
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var didOpenFullScreen = false
    private var asset: FVPAsset?
    
    var player: FVPVideoPlayer!
    var controls: FVPControls!
    var progressBar: FVPProgressBar!
    var placeholder: FVPPlaceholder!
    var loader: FVPLoader!
    var fullScreen: FVPFullScreen!
    
    public var height: CGFloat {
        min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 9 / 16
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard !didOpenFullScreen else { return }
        
        UIDevice.current.orientation.isPortrait
        ? fullScreen.close()
        : openFullScreen(source: .rotate)
    }
    
    public func setup(with url: URL) {
        let asset = FVPAsset(url: url)
        self.asset = asset
        player.setup(with: asset)
    }
    
    public func setup(with asset: FVPAsset) {
        self.asset = asset
        player.setup(with: asset)
    }
}

// MARK: Private

private extension FVPViewController {
    func setupUI() {
        addContainer()
        player.add(to: playerContainerView)
        controls.add(to: playerContainerView)
        progressBar.add(to: playerContainerView)
        loader.add(to: playerContainerView)
        placeholder.add(to: playerContainerView)
    }
    
    func addContainer() {
        view.addSubview(playerContainerView)
        
        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func openFullScreen(source: Source) {
        playerContainerView.removeFromSuperview()
        
        fullScreen.open(playerContainerView, source: source)
        progressBar.updateScreenMode(.fullScreen)
        
        didOpenFullScreen = true
    }
}

// MARK: FoxVideoPlayerViewDelegate

extension FVPViewController: FVPVideoPlayerDelegate {
    public func updatePlayerState(_ player: FVPVideoPlayer, state: FVPVideoState) {
        loader.stop()
        controls.loading(false)
        controls.setPlayerState(state)
        switch state {
        case .ready:
            placeholder.hide()
        case .failed:
            placeholder.show()
        }
    }
    
    public func updatePlaybackState(_ player: FVPVideoPlayer, state: FVPPlaybackState) {
        controls.setPlaybackState(state)
    }
    
    public func updateTime(_ player: FVPVideoPlayer, time: TimeInterval, duration: TimeInterval) {
        progressBar.setTime(time, duration: duration)
    }
    
    public func willUpdateTime(_ player: FVPVideoPlayer, isCompleted: Bool, from: FVPUpdateTimeFrom) {
        if isCompleted {
            controls.setPlaybackState(.completed)
        } else {
            guard from == .progressBar else { return }
            loader.start()
            controls.loading(true)
        }
    }
    
    public func didUpdateTime(_ player: FVPVideoPlayer, isCompleted: Bool) {
        progressBar.didUpdateTime()
        guard !isCompleted else { return }
        loader.stop()
        controls.loading(false)
        
    }
    
    public func updatePreviewImage(_ player: FVPVideoPlayer, image: UIImage?) {
        progressBar.setPreviewImage(image)
    }
}

// MARK: FoxVideoPlayerControlsViewDelegate

extension FVPViewController: FVPControlsDelegate {
    public func didTapPlay(_ controls: FVPControls, isPlay: Bool) {
        if isPlay, !progressBar.isVisible {
            progressBar.setHidden(false)
        }
        
        isPlay ? player.play() : player.pause()
    }
    
    public func didTapSeek(_ controls: FVPControls, interval: TimeInterval) {
        player.seekInterval(interval)
    }
    
    public func updateVisibleControls(_ controls: FVPControls, isVisible: Bool) {
        isVisible
            ? progressBar.show()
            : progressBar.hide()
    }
    
    public func didTapReplay(_ controls: FVPControls) {
        player.relplay()
    }
}

// MARK: FoxVideoPlayerProgressBarViewDelegate

extension FVPViewController: FVPProgressBarDelegate {
    public func setTime(_ progressBar: FVPProgressBar, time: TimeInterval) {
        player.setTime(time)
    }
    
    public func didBeginMovingPin(_ progressBar: FVPProgressBar, state: FVPProgressBarState) {
        switch state {
        case .visible:
            controls.setVisibleControls(false)
        case .hidden:
            controls.setDarkenBackground(true)
        }
    }
    
    public func didEndMovingPin(_ progressBar: FVPProgressBar, state: FVPProgressBarState) {
        switch state {
        case .visible:
            controls.setVisibleControls(true)
        case .hidden:
            controls.setDarkenBackground(false)
        }
    }
    
    public func didTapChangeScreenMode(_ progressBar: FVPProgressBar) {
        if didOpenFullScreen {
            fullScreen.close()
            progressBar.updateScreenMode(.default)
        } else {
            openFullScreen(source: .button)
            progressBar.updateScreenMode(.fullScreen)
        }
    }
    
    public func renderImage(_ progressBar: FVPProgressBar, time: TimeInterval) {
        let previewSize = player.previewImageSize()
        progressBar.setPreviewImageSize(previewSize)
        player.renderPreviewImage(for: time)
    }
}

// MARK: FullScreenPlayerViewControllerDelegate

extension FVPViewController: FVPFullScreenDelegate {
    public func willHideFullScreen(_ controller: FVPFullScreen) {
        
    }
    
    public func didHideFullScreen(_ controller: FVPFullScreen) {
        addContainer()
        
        progressBar.updateScreenMode(.default)
        
        didOpenFullScreen = false
    }
}

// MARK: FoxVideoPlayerPlaceholderDelegate

extension FVPViewController: FVPPlaceholderDelegate {
    public func repeate(_ placeholder: FVPPlaceholder) {
        guard let asset = asset else { return }
        player.setup(with: asset)
        placeholder.hide()
        loader.start()
    }
}
