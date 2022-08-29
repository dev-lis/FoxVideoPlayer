//
//  FVPControlsView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

public class FVPControlsView: UIView {
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
        button.imageView?.tintColor = settings.color.playPause
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(settings.image.play, for: .normal)
        button.setImage(settings.image.pause, for: .selected)
        button.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        return button
    }()

    private lazy var replayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.imageView?.tintColor = settings.color.startPlayReplay
        button.setImage(settings.image.startPlay, for: .normal)
        button.setImage(settings.image.replay, for: .selected)
        button.addTarget(self, action: #selector(didTapReplay), for: .touchUpInside)
        return button
    }()

    private lazy var backwardButton: FVPSeekButton = {
        let button = FVPSeekButton(direction: .backward)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.seekImage = settings.image.backward
        button.color = settings.color.seek
        button.setVisible(false)
        button.didTap = { [weak self] interval in
            guard let self = self else { return }
            self.delegate?.didTapSeek(self, interval: TimeInterval(interval))
        }
        return button
    }()

    private lazy var forwardButton: FVPSeekButton = {
        let button = FVPSeekButton(direction: .forward)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.seekImage = settings.image.forward
        button.color = settings.color.seek
        button.setVisible(false)
        button.didTap = { [weak self] interval in
            guard let self = self else { return }
            self.delegate?.didTapSeek(self, interval: TimeInterval(interval))
        }
        return button
    }()
    
    private var centerWidthConstraint: NSLayoutConstraint!
    private var playPauseCenterYConstraint: NSLayoutConstraint!
    private var playPauseWidthConstraint: NSLayoutConstraint!
    private var startPlayReplayCenterYConstraint: NSLayoutConstraint!
    private var startPlayReplayWidthConstraint: NSLayoutConstraint!
    private var backwardCenterXConstraint: NSLayoutConstraint!
    private var backwardCenterYConstraint: NSLayoutConstraint!
    private var backwardWidthConstraint: NSLayoutConstraint!
    private var forwardCenterXConstraint: NSLayoutConstraint!
    private var forwardCenterYConstraint: NSLayoutConstraint!
    private var forwardWidthConstraint: NSLayoutConstraint!

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

    private var state: FVPPlaybackState = .pause

    public weak var delegate: FVPControlsDelegate?
    
    private let settings: FVPControlsSettings
    
    public init(settings: FVPControlsSettings) {
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
        
        updateLayout()
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
        
        centerWidthConstraint = centerView.widthAnchor.constraint(equalToConstant: 0)
        playPauseCenterYConstraint = playbackButton.centerYAnchor.constraint(equalTo: centerView.centerYAnchor)
        playPauseWidthConstraint = playbackButton.widthAnchor.constraint(equalToConstant: 0)
        startPlayReplayCenterYConstraint = replayButton.centerYAnchor.constraint(equalTo: centerView.centerYAnchor)
        startPlayReplayWidthConstraint = replayButton.widthAnchor.constraint(equalToConstant: 0)
        backwardCenterXConstraint = backwardButton.centerXAnchor.constraint(equalTo: leftView.centerXAnchor)
        backwardCenterYConstraint = backwardButton.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
        backwardWidthConstraint = backwardButton.widthAnchor.constraint(equalToConstant: 0)
        forwardCenterXConstraint = forwardButton.centerXAnchor.constraint(equalTo: rightView.centerXAnchor)
        forwardCenterYConstraint = forwardButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor)
        forwardWidthConstraint = forwardButton.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            centerWidthConstraint,
            rightView.widthAnchor.constraint(equalTo: leftView.widthAnchor),

            playbackButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            playbackButton.heightAnchor.constraint(equalTo: playbackButton.widthAnchor),
            playPauseWidthConstraint,
            playPauseCenterYConstraint,

            replayButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            replayButton.heightAnchor.constraint(equalTo: replayButton.widthAnchor),
            startPlayReplayCenterYConstraint,
            startPlayReplayWidthConstraint,

            backwardButton.heightAnchor.constraint(equalTo: backwardButton.widthAnchor),
            backwardCenterXConstraint,
            backwardCenterYConstraint,
            backwardWidthConstraint,
            
            forwardButton.heightAnchor.constraint(equalTo: forwardButton.widthAnchor),
            forwardCenterXConstraint,
            forwardCenterYConstraint,
            forwardWidthConstraint
        ])
    }

    private func updateLayout() {
        
        // Center Area
        
        if settings.size.centerAreaWidth <= 40 {
            centerWidthConstraint.constant = 40
        } else if settings.size.centerAreaWidth >= bounds.width / 3 {
            centerWidthConstraint.constant = bounds.width / 3
        } else {
            centerWidthConstraint.constant = settings.size.centerAreaWidth
        }
        
        // Play & Pause Button
        
        if bounds.height / 2 + settings.size.playPauseCenterYInset <= 0 {
            playPauseCenterYConstraint.constant = settings.size.playPauseButtonSize / 2 - bounds.height / 2
        } else if settings.size.playPauseCenterYInset - bounds.height / 2 >= 0 {
            playPauseCenterYConstraint.constant = bounds.height / 2 - settings.size.playPauseButtonSize / 2
        } else {
            playPauseCenterYConstraint.constant = settings.size.playPauseCenterYInset
        }
        
        if settings.size.playPauseButtonSize > 8 {
            playPauseWidthConstraint.constant = settings.size.playPauseButtonSize
        } else {
            playPauseWidthConstraint.constant = 8
        }
        
        // Start play & Replay Button
        
        if bounds.height / 2 + settings.size.startPlayReplayCenterYInset <= 0 {
            startPlayReplayCenterYConstraint.constant = settings.size.startPlayReplayButtonSize / 2 - bounds.height / 2
        } else if settings.size.startPlayReplayCenterYInset - bounds.height / 2 >= 0 {
            startPlayReplayCenterYConstraint.constant = bounds.height / 2 - settings.size.startPlayReplayButtonSize / 2
        } else {
            startPlayReplayCenterYConstraint.constant = settings.size.startPlayReplayCenterYInset
        }
            
        if settings.size.startPlayReplayButtonSize > 8 {
            startPlayReplayWidthConstraint.constant = settings.size.startPlayReplayButtonSize
        } else {
            startPlayReplayWidthConstraint.constant = 8
        }
        
        // Seek Buttons
        
        let sideWidth = (bounds.width - settings.size.centerAreaWidth) / 2
        if sideWidth / 2 + settings.size.seekButtonsCenterXInset <= 0 {
            backwardCenterXConstraint.constant = settings.size.seekButtonsSize / 2 - sideWidth / 2
            forwardCenterXConstraint.constant = sideWidth / 2 - settings.size.seekButtonsSize / 2
        } else if settings.size.seekButtonsCenterXInset - sideWidth / 2 >= 0 {
            backwardCenterXConstraint.constant = sideWidth / 2 - settings.size.seekButtonsSize / 2
            forwardCenterXConstraint.constant = settings.size.seekButtonsSize / 2 - sideWidth / 2
        } else {
            backwardCenterXConstraint.constant = settings.size.seekButtonsCenterXInset
            forwardCenterXConstraint.constant = -settings.size.seekButtonsCenterXInset
        }
        
        if bounds.height / 2 + settings.size.seekButtonsCenterYInset <= 0 {
            backwardCenterYConstraint.constant = settings.size.seekButtonsSize / 2 - bounds.height / 2
            forwardCenterYConstraint.constant = settings.size.seekButtonsSize / 2 - bounds.height / 2
        } else if settings.size.seekButtonsCenterYInset - bounds.height / 2 >= 0 {
            backwardCenterYConstraint.constant = bounds.height / 2 - settings.size.seekButtonsSize / 2
            forwardCenterYConstraint.constant = bounds.height / 2 - settings.size.seekButtonsSize / 2
        } else {
            backwardCenterYConstraint.constant = settings.size.seekButtonsCenterYInset
            forwardCenterYConstraint.constant = settings.size.seekButtonsCenterYInset
        }
        
        if settings.size.seekButtonsSize > 8 {
            backwardWidthConstraint.constant = settings.size.seekButtonsSize
            forwardWidthConstraint.constant = settings.size.seekButtonsSize
        } else {
            backwardWidthConstraint.constant = 8
            forwardWidthConstraint.constant = 8
        }
    }
}

// MARK: - FoxVideoPlayerControls

extension FVPControlsView: FVPControls {
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

    public func setPlayerState(_ state: FVPVideoState) {
        switch state {
        case .ready:
            replayButton.isHidden = false
            playbackButton.isHidden = true
        default:
            replayButton.isHidden = true
            playbackButton.isHidden = true
        }
    }

    public func setPlaybackState(_ state: FVPPlaybackState) {
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
        ? settings.color.darken
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

private extension FVPControlsView {
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

private extension FVPControlsView {
    func showControls() {
        if state != .completed {
            backwardButton.setVisible(true)
            forwardButton.setVisible(true)
            playbackButton.alpha = 1
        }

        backgroundColor = settings.color.darken

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

extension FVPControlsView: UIGestureRecognizerDelegate {
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

