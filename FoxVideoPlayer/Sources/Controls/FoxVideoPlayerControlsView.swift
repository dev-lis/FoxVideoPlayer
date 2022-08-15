//
//  FoxVideoPlayerControlsView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

public class FoxVideoPlayerControlsView: UIView {
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leftView, centerView, rightView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var leftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var centerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var rightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var playbackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.adjustsImageWhenHighlighted = false
        button.isHidden = true
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(settings.images.play, for: .normal)
        button.setImage(settings.images.pause, for: .selected)
        button.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        return button
    }()

    private lazy var replayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.imageView?.tintColor = .white
        button.setImage(settings.images.startPlay, for: .normal)
        button.setImage(settings.images.replay, for: .selected)
        button.addTarget(self, action: #selector(didTapReplay), for: .touchUpInside)
        return button
    }()

    private lazy var backwardButton: SeekButton = {
        let button = SeekButton(direction: .backward)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.seekImage = settings.images.backward
        button.setVisible(false)
        button.didTap = { [weak self] interval in
            guard let self = self else { return }
            self.delegate?.didTapSeek(self, interval: TimeInterval(interval))
        }
        return button
    }()

    private lazy var forwardButton: SeekButton = {
        let button = SeekButton(direction: .forward)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.seekImage = settings.images.forward
        button.setVisible(false)
        button.didTap = { [weak self] interval in
            guard let self = self else { return }
            self.delegate?.didTapSeek(self, interval: TimeInterval(interval))
        }
        return button
    }()
    
    private var widthAnchorConstraint: NSLayoutConstraint!
    private var playPauseCenterYConstraint: NSLayoutConstraint!

    private var animationItem: DispatchWorkItem?

    private var visible: Bool = false {
        didSet {
            UIView.animate(withDuration: settings.animateDuration) {
                self.visible
                    ? self.showControls()
                    : self.hideControls()
            }
        }
    }

    private var addedGestures = false
    private var didLayout = false

    private var state: FoxVideoPlaybackState = .pause

    public weak var delegate: FoxVideoPlayerControlsDelegate?
    
    private let settings: FoxVideoPlayerControlsSettings
    
    public init(settings: FoxVideoPlayerControlsSettings) {
        self.settings = settings
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !didLayout else { return }
        didLayout = true
        
        if settings.size.centerAreaWidth <= 40 {
            widthAnchorConstraint.constant = 40
        } else if settings.size.centerAreaWidth >= bounds.width / 3 {
            widthAnchorConstraint.constant = bounds.width / 3
        } else {
            widthAnchorConstraint.constant = settings.size.centerAreaWidth
        }
        
        if bounds.height / 2 + settings.size.playPauseCenterYInset <= 0 {
            playPauseCenterYConstraint.constant = settings.size.playPauseSize / 2 - bounds.height / 2
        } else if settings.size.playPauseCenterYInset - bounds.height / 2 >= 0 {
            playPauseCenterYConstraint.constant = bounds.height / 2 - settings.size.playPauseSize / 2
        } else {
            playPauseCenterYConstraint.constant = settings.size.playPauseCenterYInset
        }
    }

    private func setupGestures() {
        if addedGestures { return }

        let tap = UITapGestureRecognizer(target: self, action: nil)
        tap.delegate = self
        addGestureRecognizer(tap)
        
        guard settings.isEnableSeekOnDoubleTap else { return }

        let backSingleTapGesture = UITapGestureRecognizer(target: self, action: nil)
        backSingleTapGesture.numberOfTapsRequired = 1
        backSingleTapGesture.delegate = self
        leftView.addGestureRecognizer(backSingleTapGesture)

        let backDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGoBackward))
        backDoubleTapGesture.numberOfTapsRequired = 2
        leftView.addGestureRecognizer(backDoubleTapGesture)
        backSingleTapGesture.require(toFail: backDoubleTapGesture)

        let frontSingleTapGesture = UITapGestureRecognizer(target: self, action: nil)
        frontSingleTapGesture.numberOfTapsRequired = 1
        frontSingleTapGesture.delegate = self
        rightView.addGestureRecognizer(frontSingleTapGesture)

        let frontDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGoForward))
        frontDoubleTapGesture.numberOfTapsRequired = 2
        rightView.addGestureRecognizer(frontDoubleTapGesture)
        frontSingleTapGesture.require(toFail: frontDoubleTapGesture)
    }

    private func setupUI() {
        clipsToBounds = true

        addSubview(mainStackView)
        centerView.addSubview(playbackButton)
        centerView.addSubview(replayButton)
        leftView.addSubview(backwardButton)
        rightView.addSubview(forwardButton)
        
        widthAnchorConstraint = centerView.widthAnchor.constraint(equalToConstant: 0)
        playPauseCenterYConstraint = playbackButton.centerYAnchor.constraint(equalTo: centerView.centerYAnchor)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            widthAnchorConstraint,
            rightView.widthAnchor.constraint(equalTo: leftView.widthAnchor),

            playbackButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            playbackButton.widthAnchor.constraint(equalToConstant: settings.size.playPauseSize),
            playbackButton.heightAnchor.constraint(equalTo: playbackButton.widthAnchor),
            playPauseCenterYConstraint,

            replayButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            replayButton.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: settings.size.startPlayReplayCenterYInset),
            replayButton.widthAnchor.constraint(equalToConstant: settings.size.startPlayReplaySize),
            replayButton.heightAnchor.constraint(equalTo: replayButton.widthAnchor),

            backwardButton.rightAnchor.constraint(equalTo: leftView.rightAnchor, constant: -settings.size.backwardForwardCenterXInset),
            backwardButton.centerYAnchor.constraint(equalTo: leftView.centerYAnchor, constant: settings.size.backwardForwardCenterYInset),
            backwardButton.widthAnchor.constraint(equalToConstant: settings.size.backwardForwardSize),
            backwardButton.heightAnchor.constraint(equalTo: backwardButton.widthAnchor),

            forwardButton.leftAnchor.constraint(equalTo: rightView.leftAnchor, constant: settings.size.backwardForwardCenterXInset),
            forwardButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor, constant: settings.size.backwardForwardCenterYInset),
            forwardButton.widthAnchor.constraint(equalToConstant: settings.size.backwardForwardSize),
            forwardButton.heightAnchor.constraint(equalTo: forwardButton.widthAnchor)
        ])
    }
}

// MARK: - FoxVideoPlayerControls

extension FoxVideoPlayerControlsView: FoxVideoPlayerControls {
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

    public func setPlayerState(_ state: FoxVideoPlayerState) {
        switch state {
        case .ready:
            replayButton.isHidden = false
            playbackButton.isHidden = true
        default:
            break
        }
    }

    public func setPlaybackState(_ state: FoxVideoPlaybackState) {
        switch state {
        case .play:
            replayButton.isHidden = true
            playbackButton.isSelected = true
        case .pause:
            replayButton.isHidden = true
            playbackButton.isSelected = false
        case .completed:
            replayButton.isHidden = false
            playbackButton.isSelected = false
            playbackButton.isHidden = true
            backwardButton.isHidden = true
            forwardButton.isHidden = true
            backwardButton.setVisible(false)
            forwardButton.setVisible(false)
        }
    }

    public func setVisibleControls(_ isVisible: Bool) {
        backwardButton.setVisible(isVisible)
        forwardButton.setVisible(isVisible)
        playbackButton.alpha = isVisible ? 1 : 0

        isVisible
            ? startHideTaskWithDelay()
            : animationItem?.cancel()
    }
    
    public func setDarkenBackground(_ isDraken: Bool) {
        backgroundColor = isDraken
        ? settings.darkenColor
        : .clear
    }

    public func updateStateForFullScreen(isPause: Bool) {
        playbackButton.isSelected = !isPause
        playbackButton.isHidden = false
        backwardButton.alpha = 1
        forwardButton.alpha = 1

        setupGestures()
        addedGestures = true
    }

    public func updatePlayPauseButton(isPlaying: Bool) {
        playbackButton.isSelected = isPlaying
    }

    public func loading(_ isLoading: Bool) {
        replayButton.isHidden = true
        backwardButton.isHidden = isLoading
        forwardButton.isHidden = isLoading
        playbackButton.isHidden = isLoading
    }
    
    public func resetVisibleControls() {
        startHideTask()
    }
}

// MARK: - Action

private extension FoxVideoPlayerControlsView {
    @objc func didTapPlayPause() {
        delegate?.didTapPlay(self, isPlay: !playbackButton.isSelected)
        playbackButton.isSelected.toggle()

        guard visible else { return }

        playbackButton.isSelected
            ? startHideTaskWithDelay()
            : animationItem?.cancel()
    }

    @objc func didTapReplay() {
        if !addedGestures {
            setupGestures()
            addedGestures = true
            playbackButton.alpha = 0
            replayButton.isSelected = true
            
            delegate?.didTapPlay(self, isPlay: !playbackButton.isSelected)
        }
        
        setPlayerState(.ready)
        hideControls()

        delegate?.didTapReplay(self)

        playbackButton.isSelected = true
        replayButton.isHidden = true
        backwardButton.isHidden = false
        forwardButton.isHidden = false
    }

    @objc func didTapGoBackward() {
        guard state != .completed else { return }

        backwardButton.seekAnimation()
        animationItem?.cancel()
        startHideTaskWithDelay()
    }

    @objc func didTapGoForward() {
        guard state != .completed else { return }

        forwardButton.seekAnimation()
        animationItem?.cancel()
        startHideTaskWithDelay()
    }
}

//MARK: Private
private extension FoxVideoPlayerControlsView {
    func showControls() {
        if state != .completed {
            backwardButton.setVisible(true)
            forwardButton.setVisible(true)
            playbackButton.alpha = 1
        }

        backgroundColor = settings.darkenColor

        delegate?.updateVisibleControls(self, isVisible: true)

        startHideTaskWithDelay()
    }

    func hideControls() {
        backwardButton.setVisible(false)
        forwardButton.setVisible(false)
        playbackButton.alpha = 0

        backgroundColor = .clear

        delegate?.updateVisibleControls(self, isVisible: false)
    }

    func startHideTask() {
        animationItem?.cancel()
        animationItem = DispatchWorkItem {
            self.visible.toggle()
        }
    }

    func startHideTaskWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.playbackButton.isSelected {
                self.animationItem?.cancel()
                return
            }
            self.startHideTask()
            guard let task = self.animationItem else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.settings.autoHideControlsDelay, execute: task)
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension FoxVideoPlayerControlsView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if settings.isEnableSeekOnDoubleTap {
            startHideTask()
            guard let item = animationItem else { return true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: item)
        } else {
            visible.toggle()
        }
        return true
    }
}

