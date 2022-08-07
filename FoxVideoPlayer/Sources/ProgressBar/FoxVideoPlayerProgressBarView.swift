//
//  FoxVideoPlayerProgressBarView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit
import AVKit

public class FoxVideoPlayerProgressBarView: UIView {
    private lazy var progressSlider: FoxVideoPlayerProgressSlider = {
        let slider = FoxVideoPlayerProgressSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.movingOnRaised = { [weak self] isMoving in
            guard let self = self else { return }
            
            if isMoving {
                self.hideElements()
                self.delegate?.didBeginMovingPin(self, state: .visible)
            } else {
                self.showElements()
                self.delegate?.didEndMovingPin(self, state: .visible)
            }
        }
        slider.movingOnHidden = { [weak self] isMoving in
            guard let self = self else { return }
            isMoving
                ? self.delegate?.didBeginMovingPin(self, state: .hidden)
                : self.delegate?.didEndMovingPin(self, state: .hidden)
        }
        slider.time = { [weak self] time in
            guard let self = self else { return }
            self.delegate?.setTime(self, time: TimeInterval(time))
        }
        slider.imageForTime = { [weak self] time in
            guard let self = self else { return }
            self.delegate?.renderImage(self, time: time)
        }
        return slider
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = settings.timerLabelFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.isHidden = true
        return label
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [screenModeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.isHidden = true
        return stackView
    }()

    private lazy var screenModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = .white
        button.imageEdgeInsets.top = -4
        button.addTarget(self, action: #selector(didTapFullScreen), for: .touchUpInside)
        return button
    }()
    
    private var bottomConstraint: NSLayoutConstraint!

    private var sliderTopInset: CGFloat {
        progressSlider.sliderTopInset + progressSlider.frame.origin.y
    }

    public weak var delegate: FoxVideoPlayerProgressBarDelegate?
    
    private var didStartPlay = false

    private var rate: Float {
        settings.startRate
    }
    
    private var screenMode: FoxScreenMode
    
    private var settings: FoxVideoPlayerProgressBarSettings
    
    public init(settings: FoxVideoPlayerProgressBarSettings) {
        self.settings = settings
        self.screenMode = settings.screenMode
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        isHidden = true
        
        addSubview(buttonsStackView)
        addSubview(progressSlider)
        addSubview(timerLabel)

        NSLayoutConstraint.activate([
            progressSlider.topAnchor.constraint(equalTo: topAnchor),
            progressSlider.leftAnchor.constraint(equalTo: leftAnchor),
            progressSlider.rightAnchor.constraint(equalTo: rightAnchor),
            progressSlider.heightAnchor.constraint(equalToConstant: 34),

            timerLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor),
            timerLabel.leftAnchor.constraint(equalTo: progressSlider.leftAnchor, constant: settings.timerLeftInset),

            buttonsStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -16),
            buttonsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -settings.buttonsStackRightInset),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateScreenMode(.default)
    }

    private func showAnimation() {
        progressSlider.showAnimation()

        timerLabel.isHidden = false
        buttonsStackView.isHidden = false
    }

    private func hideAnimation() {
        progressSlider.hideAnimation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.timerLabel.isHidden = true
            self.buttonsStackView.isHidden = true
        }
    }
}

extension FoxVideoPlayerProgressBarView: FoxVideoPlayerProgressBar {
    public var isVisible: Bool {
        !isHidden
    }
    
    public func add(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        
        bottomConstraint = bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: settings.barHeight - sliderTopInset
        )
        
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor),
            heightAnchor.constraint(equalToConstant: settings.barHeight),
            bottomConstraint,
        ])
    }
    
    public func setHidden(_ isHidden: Bool) {
        self.isHidden = isHidden
    }
    
    public func setTime(_ time: TimeInterval, duration: TimeInterval) {
        didStartPlay = true
        
        progressSlider.duration = CGFloat(duration)
        progressSlider.currentTime = CGFloat(time)
        let progress = CGFloat(time / duration)
        progressSlider.setProgress(progress)

        let timeValue = Int(time)
        let durationValue = Int(duration)

        let timePart = secondsToHoursMinutesSeconds(seconds: timeValue)
        let durationPart = secondsToHoursMinutesSeconds(seconds: durationValue)

        var timeString = String(timePart.minutes) + ":" + getTimeString(timeValue: timePart.seconds)
        var durationString = String(durationPart.minutes) + ":" + getTimeString(timeValue: durationPart.seconds)
        if durationPart.hours != 0 {
            timeString = String(timePart.hours)
                + ":"
                + getTimeString(timeValue: timePart.minutes)
                + ":"
                + getTimeString(timeValue: timePart.seconds)

            durationString = String(durationPart.hours)
                + ":"
                + getTimeString(timeValue: durationPart.minutes)
                + ":"
                + getTimeString(timeValue: durationPart.seconds)
        }
        timerLabel.text = timeString + " / " + durationString
    }
    
    public func didUpdateTime() {
        progressSlider.didUpdateTime()
    }
    
    public func updateScreenMode(_ mode: FoxScreenMode) {
        screenMode = mode

        let image = screenMode == .default
            ? UIImage(systemName: "arrow.up.left.and.arrow.down.right")
            : UIImage(systemName: "arrow.down.right.and.arrow.up.left")
        screenModeButton.setImage(image, for: .normal)
        updateFullScreenButton()
    }
    
    public func setPreviewImage(_ image: UIImage?) {
        progressSlider.setPreviewImage(image)
    }
    
    public func setPreviewImageSize(_ size: CGSize) {
        progressSlider.setPreviewImageSize(size)
    }
    
    public func show() {
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: settings.animateDuration) {
            self.superview?.layoutIfNeeded()
        }
        showAnimation()
    }
    
    public func hide() {
        let inset = screenMode == .default ? sliderTopInset : 0
        bottomConstraint?.constant = frame.height - inset
        UIView.animate(withDuration: settings.animateDuration) {
            self.superview?.layoutIfNeeded()
        }
        hideAnimation()
    }
    
    public func updateFullScreenButton() {
        progressSlider.layoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.screenModeButton.isSelected = false
        }
    }
}

// MARK: Action
private extension FoxVideoPlayerProgressBarView {
    @objc func didTapRate() {
        
    }

    @objc func didTapPip(_ sender: UIButton) {
        
    }

    @objc func didTapFullScreen(_ sender: UIButton) {
        delegate?.didTapChangeScreenMode(self)
    }
}

// MARK: Private
private extension FoxVideoPlayerProgressBarView {
    func secondsToHoursMinutesSeconds(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (hours: seconds / 3600, minutes: (seconds % 3600) / 60, seconds: (seconds % 3600) % 60)
    }

    func getTimeString(timeValue: Int) -> String {
        guard timeValue >= 0, timeValue < 10 else { return String(timeValue) }
        return "0" + String(timeValue)
    }

    func showElements() {
        UIView.animate(withDuration: settings.elementAnimateDuration) {
            self.timerLabel.alpha = 1
            self.buttonsStackView.alpha = 1
        }
    }

    func hideElements() {
        UIView.animate(withDuration: settings.elementAnimateDuration) {
            self.timerLabel.alpha = 0
            self.buttonsStackView.alpha = 0
        }
    }
}

