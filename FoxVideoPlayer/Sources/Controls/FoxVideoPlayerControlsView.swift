//
//  FoxVideoPlayerControlsView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

public protocol FoxVideoPlayerControlsViewDelegate: AnyObject {
    func didTapPlay(_ controls: FoxVideoPlayerControlsView, isPlay: Bool)
    func didTapReplay(_ controls: FoxVideoPlayerControlsView)
    func didTapSeek(_ controls: FoxVideoPlayerControlsView, interval: TimeInterval)
    func updateVisibleControls(_ controls: FoxVideoPlayerControlsView, isVisible: Bool)
}

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
        
        let playConfiguration = UIImage.SymbolConfiguration(pointSize: 40)
        let playImage = UIImage(systemName: "play.fill", withConfiguration: playConfiguration)
        button.setImage(playImage, for: .normal)
        
        let pauseConfiguration = UIImage.SymbolConfiguration(pointSize: 40)
        let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: pauseConfiguration)
        button.setImage(pauseImage, for: .selected)
        
        button.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        return button
    }()

    private lazy var replayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.imageView?.tintColor = .white
        
        let playConfiguration = UIImage.SymbolConfiguration(pointSize: 50)
        let playImage = UIImage(systemName: "play.fill", withConfiguration: playConfiguration)
        button.setImage(playImage, for: .normal)
        
        let replayConfiguration = UIImage.SymbolConfiguration(pointSize: 50)
        let replayImage = UIImage(systemName: "gobackward", withConfiguration: replayConfiguration)
        button.setImage(replayImage, for: .selected)
        
        button.addTarget(self, action: #selector(didTapReplay), for: .touchUpInside)
        return button
    }()

    private lazy var backwardButton: SeekButton = {
        let button = SeekButton(direction: .backward)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        button.seekImage = UIImage(systemName: "gobackward", withConfiguration: configuration)
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
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        button.seekImage = UIImage(systemName: "goforward", withConfiguration: configuration)
        button.setVisible(false)
        button.didTap = { [weak self] interval in
            guard let self = self else { return }
            self.delegate?.didTapSeek(self, interval: TimeInterval(interval))
        }
        return button
    }()
    
    private lazy var loadIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
        view.startAnimating()
        return view
    }()

    private var hideTask: DispatchWorkItem?

    var visible: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.visible
                    ? self.showControls()
                    : self.hideControls()
            }
        }
    }

    private var addedGestures = false

    private var state: FoxVideoPlaybackState = .pause

    public var updatePlaybackState: ((FoxVideoPlaybackState) -> Void)?

    public weak var delegate: FoxVideoPlayerControlsViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestures() {
        if addedGestures { return }

        let tap = UITapGestureRecognizer(target: self, action: nil)
        tap.delegate = self
        addGestureRecognizer(tap)

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
    
    public func add(to view: UIView) {
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
        updatePlaybackState?(state)

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
            : hideTask?.cancel()
    }
    
    public func setDarkenBackground(_ isDraken: Bool) {
        backgroundColor = isDraken
        ? .black.withAlphaComponent(0.46)
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
        loadIndicator.isHidden = !isLoading

        updatePlaybackState?(state)
    }
    
    public func resetVisibleControls() {
        startHideTask()
    }

    private func setupUI() {
        clipsToBounds = true

        addSubview(mainStackView)
        centerView.addSubview(playbackButton)
        centerView.addSubview(replayButton)
        leftView.addSubview(backwardButton)
        rightView.addSubview(forwardButton)
        addSubview(loadIndicator)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            centerView.widthAnchor.constraint(equalToConstant: 80),
            rightView.widthAnchor.constraint(equalTo: leftView.widthAnchor),

            playbackButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            playbackButton.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: -16),
            playbackButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            playbackButton.heightAnchor.constraint(equalTo: playbackButton.widthAnchor),

            replayButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            replayButton.centerYAnchor.constraint(equalTo: playbackButton.centerYAnchor, constant: 8),
            replayButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            replayButton.heightAnchor.constraint(equalTo: replayButton.widthAnchor),

            backwardButton.rightAnchor.constraint(equalTo: leftView.rightAnchor, constant: -40),
            backwardButton.centerYAnchor.constraint(equalTo: leftView.centerYAnchor, constant: -16),
            backwardButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            backwardButton.heightAnchor.constraint(equalTo: backwardButton.widthAnchor),

            forwardButton.leftAnchor.constraint(equalTo: rightView.leftAnchor, constant: 40),
            forwardButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor, constant: -16),
            forwardButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            forwardButton.heightAnchor.constraint(equalTo: forwardButton.widthAnchor),
            
            loadIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

//MARL: Action

private extension FoxVideoPlayerControlsView {
    @objc func didTapPlayPause() {
        delegate?.didTapPlay(self, isPlay: !playbackButton.isSelected)
        playbackButton.isSelected.toggle()
        
        updatePlaybackState?(playbackButton.isSelected ? .play : .pause)

        guard visible else { return }

        playbackButton.isSelected
            ? startHideTaskWithDelay()
            : hideTask?.cancel()
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
        hideTask?.cancel()
        startHideTaskWithDelay()
    }

    @objc func didTapGoForward() {
        guard state != .completed else { return }

        forwardButton.seekAnimation()
        hideTask?.cancel()
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

        backgroundColor = .black.withAlphaComponent(0.46)

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
        hideTask?.cancel()
        hideTask = DispatchWorkItem {
            self.visible.toggle()
        }
    }

    func startHideTaskWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.playbackButton.isSelected {
                self.hideTask?.cancel()
                return
            }
            self.startHideTask()
            guard let task = self.hideTask else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: task)
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension FoxVideoPlayerControlsView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        startHideTask()
        guard let task = hideTask else { return true }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: task)
        return true
    }
}

