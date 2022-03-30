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
    
    private lazy var playerView: FoxVideoPlayerView = {
        let view = FoxVideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var controlsView: FoxVideoPlayerControlsView = {
        let view = FoxVideoPlayerControlsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var progressBarView: FoxVideoPlayerProgressBarView = {
        let view = FoxVideoPlayerProgressBarView(settings: progressBarSettings)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private var fullScreenController: FoxFullScreenVideoPlayerViewController?
    
    private var progressBarBottomConstraint: NSLayoutConstraint!
    
    public var height: CGFloat {
        min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 9 / 16
    }
    
    private var progressBarSettings: FoxVideoPlayerProgressBarSettings = FoxVideoPlayerProgressBarSettings()
    
    public init(progressBarSettings: FoxVideoPlayerProgressBarSettings? = nil) {
        self.progressBarSettings = progressBarSettings ?? FoxVideoPlayerProgressBarSettings()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard fullScreenController == nil else { return }
        
        UIDevice.current.orientation.isPortrait
        ? fullScreenController?.close()
        : openFullScreen(source: .rotate)
    }
    
    public func setup(with url: URL) {
        let asset = FoxVideoPlayerAsset(url: url)
        playerView.setup(with: asset)
    }
    
    public func setup(with asset: FoxVideoPlayerAsset) {
        playerView.setup(with: asset)
    }
}

// MARK: Private

private extension FoxVideoPlayerViewController {
    func setupUI() {
        addContainer()
        playerView.add(to: playerContainerView)
        controlsView.add(to: playerContainerView)
        progressBarView.add(to: playerContainerView)
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
    
    func openFullScreen(source: FoxFullScreenVideoPlayerViewController.Source) {
        
        playerContainerView.removeFromSuperview()
        
        let controller = FoxFullScreenVideoPlayerViewController(playerView: playerContainerView, source: source)
        controller.delegate = self
        fullScreenController = controller
        
        UIApplication.shared.windows
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController?
            .present(controller, animated: false)
        
        progressBarView.updateScreenMode(.fullScreen)
    }
}

// MARK: FoxVideoPlayerViewDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerViewDelegate {
    public func updatePlayerState(_ player: FoxVideoPlayerView, state: FoxVideoPlayerState) {
        switch state {
        case .ready:
            controlsView.loading(false)
            controlsView.setPlayerState(state)
        case .failed:
            // TODO: handle error
            break
        }
    }
    
    public func updatePlaybackState(_ player: FoxVideoPlayerView, state: FoxVideoPlaybackState) {
        controlsView.setPlaybackState(state)
    }
    
    public func updateTime(_ player: FoxVideoPlayerView, time: TimeInterval, duration: TimeInterval) {
        progressBarView.setTime(time, duration: duration)
    }
    
    public func willUpdateTime(_ player: FoxVideoPlayerView, isCompleted: Bool, from: FoxUpdateTimeFrom) {
        if isCompleted {
            controlsView.setPlaybackState(.completed)
        } else {
            guard from == .progressBar else { return }
            controlsView.loading(true)
        }
    }
    
    public func didUpdateTime(_ player: FoxVideoPlayerView, isCompleted: Bool) {
        progressBarView.didUpdateTime()
        guard !isCompleted else { return }
        controlsView.loading(false)
        
    }
    
    public func updatePreviewImage(_ player: FoxVideoPlayerView, image: UIImage?) {
        progressBarView.setPreviewImage(image)
    }
}

// MARK: FoxVideoPlayerControlsViewDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerControlsViewDelegate {
    public func didTapPlay(_ controls: FoxVideoPlayerControlsView, isPlay: Bool) {
        if progressBarView.isHidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.progressBarView.isHidden = false
            }
        }
        isPlay ? playerView.play() : playerView.pause()
    }
    
    public func didTapSeek(_ controls: FoxVideoPlayerControlsView, interval: TimeInterval) {
        playerView.seekInterval(interval)
    }
    
    public func updateVisibleControls(_ controls: FoxVideoPlayerControlsView, isVisible: Bool) {
        isVisible
            ? progressBarView.show()
            : progressBarView.hide()
    }
    
    public func didTapReplay(_ controls: FoxVideoPlayerControlsView) {
        playerView.relplay()
    }
}

// MARK: FoxVideoPlayerProgressBarViewDelegate

extension FoxVideoPlayerViewController: FoxVideoPlayerProgressBarViewDelegate {
    public func setTime(_ progressBar: FoxVideoPlayerProgressBarView, time: TimeInterval) {
        playerView.setTime(time)
    }
    
    public func didBeginMovingPin(_ progressBar: FoxVideoPlayerProgressBarView, state: FoxProgressBarState) {
        switch state {
        case .visible:
            controlsView.setVisibleControls(false)
        case .hidden:
            controlsView.setDarkenBackground(true)
        }
    }
    
    public func didEndMovingPin(_ progressBar: FoxVideoPlayerProgressBarView, state: FoxProgressBarState) {
        switch state {
        case .visible:
            controlsView.setVisibleControls(true)
        case .hidden:
            controlsView.setDarkenBackground(false)
        }
    }
    
    public func didTapChangeScreenMode(_ progressBar: FoxVideoPlayerProgressBarView) {
        if let controller = fullScreenController {
            controller.close()
            progressBarView.updateScreenMode(.default)
        } else {
            openFullScreen(source: .button)
            progressBarView.updateScreenMode(.fullScreen)
        }
    }
    
    public func renderImage(_ progressBar: FoxVideoPlayerProgressBarView, time: TimeInterval) {
        let previewSize = self.playerView.previewImageSize()
        self.progressBarView.setPreviewImageSize(previewSize)
        playerView.renderPreviewImage(for: time)
    }
}

// MARK: FullScreenPlayerViewControllerDelegate

extension FoxVideoPlayerViewController: FoxFullScreenVideoPlayerViewControllerDelegate {
    public func didHideFullScreen(_ controller: FoxFullScreenVideoPlayerViewController) {
        addContainer()
        
        fullScreenController = nil
        
        progressBarView.updateScreenMode(.default)
    }
}
