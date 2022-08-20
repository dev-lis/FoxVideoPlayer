//
//  FoxVidePlayerViewController.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.03.2022.
//

import UIKit

public class FoxVideoPlayerViewController: UIViewController {
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var didOpenFullScreen = false
    private var asset: FoxVideoPlayerAsset?
    
    var player: FoxVideoPlayer!
    var controls: FoxVideoPlayerControls!
    var progressBar: FoxVideoPlayerProgressBar!
    var placeholder: FoxVideoPlayerPlaceholder!
    var loader: FoxVideoPlayerLoader!
    var fullScreen: FoxVideoPlayerFullScreen!
    
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
        let asset = FoxVideoPlayerAsset(url: url)
        self.asset = asset
        player.setup(with: asset)
    }
    
    public func setup(with asset: FoxVideoPlayerAsset) {
        self.asset = asset
        player.setup(with: asset)
    }
}

// MARK: Private

private extension FoxVideoPlayerViewController {
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

extension FoxVideoPlayerViewController: FoxVideoPlayerDelegate {
    public func updatePlayerState(_ player: FoxVideoPlayer, state: FoxVideoPlayerState) {
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
    
    public func updatePlaybackState(_ player: FoxVideoPlayer, state: FoxVideoPlaybackState) {
        controls.setPlaybackState(state)
    }
    
    public func updateTime(_ player: FoxVideoPlayer, time: TimeInterval, duration: TimeInterval) {
        progressBar.setTime(time, duration: duration)
    }
    
    public func willUpdateTime(_ player: FoxVideoPlayer, isCompleted: Bool, from: FoxUpdateTimeFrom) {
        if isCompleted {
            controls.setPlaybackState(.completed)
        } else {
            guard from == .progressBar else { return }
            loader.start()
            controls.loading(true)
        }
    }
    
    public func didUpdateTime(_ player: FoxVideoPlayer, isCompleted: Bool) {
        progressBar.didUpdateTime()
        guard !isCompleted else { return }
        loader.stop()
        controls.loading(false)
        
    }
    
    public func updatePreviewImage(_ player: FoxVideoPlayer, image: UIImage?) {
        progressBar.setPreviewImage(image)
    }
}

// MARK: FoxVideoPlayerControlsViewDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerControlsDelegate {
    public func didTapPlay(_ controls: FoxVideoPlayerControls, isPlay: Bool) {
        if isPlay, !progressBar.isVisible {
            progressBar.setHidden(false)
        }
        
        isPlay ? player.play() : player.pause()
    }
    
    public func didTapSeek(_ controls: FoxVideoPlayerControls, interval: TimeInterval) {
        player.seekInterval(interval)
    }
    
    public func updateVisibleControls(_ controls: FoxVideoPlayerControls, isVisible: Bool) {
        isVisible
            ? progressBar.show()
            : progressBar.hide()
    }
    
    public func didTapReplay(_ controls: FoxVideoPlayerControls) {
        player.relplay()
    }
}

// MARK: FoxVideoPlayerProgressBarViewDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerProgressBarDelegate {
    public func setTime(_ progressBar: FoxVideoPlayerProgressBar, time: TimeInterval) {
        player.setTime(time)
    }
    
    public func didBeginMovingPin(_ progressBar: FoxVideoPlayerProgressBar, state: FoxProgressBarState) {
        switch state {
        case .visible:
            controls.setVisibleControls(false)
        case .hidden:
            controls.setDarkenBackground(true)
        }
    }
    
    public func didEndMovingPin(_ progressBar: FoxVideoPlayerProgressBar, state: FoxProgressBarState) {
        switch state {
        case .visible:
            controls.setVisibleControls(true)
        case .hidden:
            controls.setDarkenBackground(false)
        }
    }
    
    public func didTapChangeScreenMode(_ progressBar: FoxVideoPlayerProgressBar) {
        if didOpenFullScreen {
            fullScreen.close()
            progressBar.updateScreenMode(.default)
        } else {
            openFullScreen(source: .button)
            progressBar.updateScreenMode(.fullScreen)
        }
    }
    
    public func renderImage(_ progressBar: FoxVideoPlayerProgressBar, time: TimeInterval) {
        let previewSize = player.previewImageSize()
        progressBar.setPreviewImageSize(previewSize)
        player.renderPreviewImage(for: time)
    }
}

// MARK: FullScreenPlayerViewControllerDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerFullScreenViewControllerDelegate {
    public func willHideFullScreen(_ controller: FoxVideoPlayerFullScreenViewController) {
        
    }
    
    public func didHideFullScreen(_ controller: FoxVideoPlayerFullScreenViewController) {
        addContainer()
        
        progressBar.updateScreenMode(.default)
        
        didOpenFullScreen = false
    }
}

// MARK: FoxVideoPlayerPlaceholderDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerPlaceholderDelegate {
    public func repeate(_ placeholder: FoxVideoPlayerPlaceholder) {
        guard let asset = asset else { return }
        player.setup(with: asset)
        placeholder.hide()
        loader.start()
    }
}
