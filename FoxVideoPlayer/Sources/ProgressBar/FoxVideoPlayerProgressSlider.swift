//
//  FoxVideoPlayerProgressSlider.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

class FoxVideoPlayerProgressSliderControl: UIControl {
    private lazy var lineLayer: FoxVideoPlayerProgressBarLineLayer = {
        let layer = FoxVideoPlayerProgressBarLineLayer()
        layer.backgroundColor = UIColor.white.withAlphaComponent(0.44).cgColor
        layer.cornerRadius = 2
        layer.masksToBounds = true
        return layer
    }()

    private lazy var pinContainerLayer: CALayer = {
        let layer = CALayer()
        layer.addSublayer(pinLayer)
        return layer
    }()

    private lazy var pinLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.systemBlue.cgColor
        layer.frame.size = CGSize(width: 12, height: 12)
        layer.cornerRadius = 6
        return layer
    }()

    private lazy var previewImageView: FoxVideoPlayerProgressPreviewImageView = {
        let view = FoxVideoPlayerProgressPreviewImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.text = " "
        return label
    }()

    public var animateDuration: TimeInterval = 0.2
    
    private var timer: Timer?

    private var previewTime: CGFloat = 0
    private var currentPinPosition: CGFloat?
    private var isAnimationCompleted = true
    private var isVisible = false
    private var isIncreased = false
    private var isSeeking = false
    private var isMagnetized = true
    private var isEnableUpdateImage = false
    
    private var isMagnetedZone: Bool {
        let inset = pinContainerLayer.bounds.width / 4 + (isVisible ? 0 : 16)
        return currentPinPosition! > lineLayer.value + inset - (isVisible ? 0 : 32) ||
        currentPinPosition! < lineLayer.value - inset
    }

    private var isMovingOnVisible: Bool = false {
        didSet {
            delegate?.movingOnRaised(self, isMoving: isMovingOnVisible)
        }
    }
    
    private var isMovingOnUnvisible: Bool = false {
        didSet {
            delegate?.movingOnHidden(self, isMoving: isMovingOnUnvisible)
        }
    }
    
    private var duration: CGFloat = 0
    private var currentTime: CGFloat = 0

    private var currentProgress: CGFloat = 0 {
        didSet {
            lineLayer.progress = currentProgress
            let inset = isVisible
                ? frame.height
                : 0
            currentPinPosition = currentProgress * (frame.width - inset)
            if !isVisible { currentPinPosition! -= frame.height / 2 }

            if !isMovingOnVisible {
                layoutSubviews()
            }
        }
    }
    
    public weak var delegate: FoxVideoPlayerProgressSliderDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isExclusiveTouch = true
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isAnimationCompleted else { return }
        
        updateLine()
        updatePin()
    }
    
    private func updateLine() {
        let lineX: CGFloat = isVisible ? 16 : 0
        let lineWidth = isVisible ? frame.size.width - 32 : frame.size.width

        lineLayer.frame = CGRect(
            x: lineX,
            y: frame.height / 2 - 2,
            width: lineWidth,
            height: 4
        )
    }
    
    private func updatePin() {
        guard !isSeeking else { return }
        
        if currentPinPosition == nil { currentPinPosition = 16 - frame.height / 2 }
        
        let inset = isVisible
            ? frame.height
            : 0
        var curPinPosition = currentProgress * (frame.width - inset)
        if !isVisible { curPinPosition -= 16 }

        if curPinPosition.isNaN {
            curPinPosition = 0
        }
        
        pinContainerLayer.frame = CGRect(
            x: curPinPosition,
            y: 0,
            width: frame.height,
            height: frame.height
        )

        let pinSide: CGFloat = isVisible
            ? isIncreased ? 20 : 12
            : isIncreased ? 20 : 0
        pinLayer.frame = CGRect(
            x: frame.height / 2 - pinLayer.frame.width / 2,
            y: pinContainerLayer.frame.height / 2 - pinLayer.frame.height / 2,
            width: pinSide,
            height: pinSide
        )

        let leftInset = FoxScreen.SafeArea.left + 8
        let currentInfoInset = currentPinPosition! + pinContainerLayer.frame.width / 2
        let currentTimeX = currentInfoInset - currentTimeLabel.frame.width / 2 > leftInset
        ?  currentInfoInset - currentTimeLabel.frame.width / 2
        : leftInset
        currentTimeLabel.sizeToFit()
        currentTimeLabel.frame.origin = CGPoint(
            x: currentTimeX,
            y: -currentTimeLabel.frame.height - 8
        )
        
        let currentPreviewX = currentInfoInset - previewImageView.frame.width / 2 > leftInset
        ?  currentInfoInset - previewImageView.frame.width / 2
        : leftInset
        previewImageView.frame.origin = CGPoint(
            x: currentPreviewX,
            y: -currentTimeLabel.frame.height - previewImageView.frame.height - 16
        )
    }
    
    private func setupUI() {
        addSubview(currentTimeLabel)
        addSubview(previewImageView)
        
        let inset = FoxScreen.SafeArea.left + 8
        currentTimeLabel.frame.origin.x = inset
        previewImageView.frame.origin.x = inset

        layer.addSublayer(lineLayer)
        layer.addSublayer(pinContainerLayer)
        pinContainerLayer.setNeedsDisplay()
        pinLayer.setNeedsDisplay()
    }
}

// MARK: FoxVideoPlayerProgressSlider

extension FoxVideoPlayerProgressSliderControl: FoxVideoPlayerProgressSlider {
    
    public var sliderTopInset: CGFloat {
        lineLayer.frame.maxY
    }
    
    public func add(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    public func didUpdateTime() {
        isSeeking = false
    }
    
    public func setCurrentTime(_ currentTime: CGFloat, of duration: CGFloat) {
        self.currentTime = currentTime
        self.duration = duration
        self.currentProgress = currentTime / duration
    }
    
    public func setPreviewImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.previewImageView.isHidden = image == nil
            self.previewImageView.image = image
        }
    }

    public func setPreviewImageSize(_ size: CGSize) {
        DispatchQueue.main.async {
            self.previewImageView.frame.size = size
            self.previewImageView.frame.origin.y = -self.currentTimeLabel.frame.height - self.previewImageView.frame.height - 16
        }
    }
    
    func updateLayout() {
        layoutSubviews()
    }
    
    func showAnimation() {
        guard isAnimationCompleted else { return }
        
        isAnimationCompleted = false

        currentPinPosition = currentProgress * (frame.width - frame.height)
        pinContainerLayer.frame = CGRect(
            x: currentPinPosition!,
            y: 0,
            width: frame.height,
            height: frame.height
        )

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isVisible = true
            self.isAnimationCompleted = true
            self.layoutSubviews()
            self.lineLayer.removeAllAnimations()
            self.pinLayer.removeAllAnimations()
            self.lineLayer.cornerRadius = 2
        }

        var animations = [CABasicAnimation]()

        let positionAnimation = CABasicAnimation(keyPath: "bounds")
        positionAnimation.fromValue = lineLayer.frame
        positionAnimation.toValue = CGRect(
            x: 16,
            y: lineLayer.frame.origin.y,
            width: frame.width - 32,
            height: lineLayer.frame.height
        )
        animations.append(positionAnimation)

        let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        cornerAnimation.fromValue = 0
        cornerAnimation.toValue = 2

        animations.append(cornerAnimation)

        let group = CAAnimationGroup()
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.duration = animateDuration
        group.animations = animations
        lineLayer.add(group, forKey: nil)

        let pinAnimation = CABasicAnimation(keyPath: "bounds")
        pinAnimation.fillMode = .forwards
        pinAnimation.isRemovedOnCompletion = false
        pinAnimation.duration = animateDuration
        pinAnimation.fromValue = pinLayer.frame
        pinAnimation.toValue = CGRect(
            x: currentPinPosition!,
            y: pinContainerLayer.frame.height / 2 - 6,
            width: 12,
            height: 12
        )
        pinLayer.add(pinAnimation, forKey: nil)

        CATransaction.commit()
    }

    func hideAnimation() {
        guard isAnimationCompleted else { return }

        isAnimationCompleted = false
        
        currentPinPosition = currentProgress * frame.width - 16
        pinContainerLayer.frame = CGRect(
            x: currentPinPosition!,
            y: 0,
            width: frame.height,
            height: frame.height
        )

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isVisible = false
            self.isAnimationCompleted = true
            self.lineLayer.removeAllAnimations()
            self.pinLayer.removeAllAnimations()
            self.layoutSubviews()
            self.lineLayer.cornerRadius = 0
        }

        var animations = [CABasicAnimation]()

        let positionAnimation = CABasicAnimation(keyPath: "bounds")
        positionAnimation.fromValue = lineLayer.frame
        positionAnimation.toValue = CGRect(
            x: 0,
            y: lineLayer.frame.origin.y,
            width: frame.width,
            height: lineLayer.frame.height
        )
        animations.append(positionAnimation)

        let corrnerAnimation = CABasicAnimation(keyPath: "cornerRadius")
        corrnerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        corrnerAnimation.fromValue = 2
        corrnerAnimation.toValue = 0

        animations.append(corrnerAnimation)

        let group = CAAnimationGroup()
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.duration = animateDuration
        group.animations = animations
        lineLayer.add(group, forKey: nil)

        let pinAnimation = CABasicAnimation(keyPath: "bounds")
        pinAnimation.fillMode = .forwards
        pinAnimation.isRemovedOnCompletion = false
        pinAnimation.duration = animateDuration
        pinAnimation.fromValue = pinLayer.frame
        pinAnimation.toValue = CGRect(
            x: 0,
            y: pinContainerLayer.frame.height / 2 - 8,
            width: 0,
            height: 0
        )
        pinLayer.add(pinAnimation, forKey: nil)

        CATransaction.commit()
    }
}

extension FoxVideoPlayerProgressSliderControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: touch.view)
        updateTime(for: point.x)
        
        isSeeking = true
        
        increasePin()

        if isVisible {
            isMovingOnVisible = true
        } else {
            isMovingOnUnvisible = true
        }
        
        startUpdatePreviewTimer()

        vibrate()

        showInfo()
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: touch.view)
        
        currentPinPosition = point.x - pinContainerLayer.frame.width / 2

        if isMagnetedZone {
            update(x: point.x)
            isMagnetized = false
        } else {
            guard !isMagnetized else { return true }
            let position = lineLayer.value + (isVisible ? 16 : 0)
            update(x: position)
            isMagnetized = true
            vibrate()
        }
        
        return true
    }
    
    override func cancelTracking(with event: UIEvent?) {
        endTracking()
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        endTracking()
    }
    
    private func endTracking() {
        decreasePin()
        
        if isVisible {
            isMovingOnVisible = false
        } else {
            isMovingOnUnvisible = false
        }
        
        if isMagnetedZone {
            delegate?.updateCurrentTime(self, time: currentTime)
        } else {
            didUpdateTime()
        }
        
        isMagnetized = true

        hideInfo()
        
        stopUpdatePreviewTimer()
    }
}

// MARK: Private

private extension FoxVideoPlayerProgressSliderControl {
    func increasePin() {
        pinLayer.frame = CGRect(
            x: pinContainerLayer.frame.width / 2 - 10,
            y: pinContainerLayer.frame.height / 2 - 10,
            width: 20,
            height: 20
        )
        pinLayer.cornerRadius = 10

        isIncreased = true
    }

    func decreasePin() {
        pinLayer.frame = CGRect(
            x: pinContainerLayer.frame.width / 2 - 6,
            y: pinContainerLayer.frame.height / 2 - 6,
            width: isVisible ? 12 : 0,
            height: isVisible ? 12 : 0
        )
        pinLayer.cornerRadius = 6

        isIncreased = false
    }

    func updatePinPosition(for position: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        pinContainerLayer.frame.origin.x = position - pinContainerLayer.frame.width / 2
        if position < lineLayer.frame.origin.x {
            pinContainerLayer.frame.origin.x = 0
        } else if position > lineLayer.frame.maxX {
            pinContainerLayer.frame.origin.x = lineLayer.frame.maxX - pinContainerLayer.frame.width / 2
        } else {
            pinContainerLayer.frame.origin.x = position - pinContainerLayer.frame.width / 2
        }

        CATransaction.commit()
    }
}

// MARK: Info

private extension FoxVideoPlayerProgressSliderControl {
    func update(x: CGFloat) {
        updatePinPosition(for: x)
        updateTime(for: x)
        updatePreview(for: x)
    }
    
    func startUpdatePreviewTimer() {
        delegate?.makeImage(self, for: previewTime)
        stopUpdatePreviewTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.makeImage(self, for: self.previewTime)
        }
    }
    
    func stopUpdatePreviewTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func showInfo() {
        UIView.animate(withDuration: animateDuration) {
            self.currentTimeLabel.alpha = 1
            self.previewImageView.alpha = 1
        }
    }
    
    func hideInfo() {
        UIView.animate(withDuration: animateDuration) {
            self.currentTimeLabel.alpha = 0
            self.previewImageView.alpha = 0
        }
    }
    
    private func vibrate() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: Time

private extension FoxVideoPlayerProgressSliderControl {
    func updateTime(for position: CGFloat) {
        currentTime = time(for: position)
        previewTime = currentTime
        let timePart = secondsToHoursMinutesSeconds(seconds: Int(currentTime))
        currentTimeLabel.text = String(timePart.minutes) + ":" + getTimeString(timeValue: timePart.seconds)
        currentTimeLabel.sizeToFit()
        
        let leftInset = FoxScreen.SafeArea.left + 8
        let rightInset = frame.width - FoxScreen.SafeArea.right - 8

        if position - currentTimeLabel.frame.width / 2 < leftInset {
            currentTimeLabel.frame.origin.x = leftInset
        } else if position + currentTimeLabel.frame.width / 2 >= rightInset {
            currentTimeLabel.frame.origin.x = rightInset - currentTimeLabel.frame.width
        } else {
            currentTimeLabel.center.x = position
        }
    }
    
    func updatePreview(for position: CGFloat) {
        let leftInset = FoxScreen.SafeArea.left + 8
        let rightInset = frame.width - FoxScreen.SafeArea.right - 8

        if position - previewImageView.frame.width / 2 < leftInset {
            previewImageView.frame.origin.x = leftInset
        } else if position + previewImageView.frame.width / 2 >= rightInset {
            previewImageView.frame.origin.x = rightInset - previewImageView.frame.width
        } else {
            previewImageView.center.x = position
        }
    }
    
    func time(for position: CGFloat) -> CGFloat {
        let insetPoint: CGFloat = isVisible ? 16 : 0
        let insetWidth: CGFloat = isVisible ? 32 : 0
        let point = position - insetPoint
        let width = frame.width - insetWidth
        return duration * point / width
    }

    func getTimeString(timeValue: Int) -> String {
        guard timeValue >= 0, timeValue < 10 else { return String(timeValue) }
        return "0" + String(timeValue)
    }

    func secondsToHoursMinutesSeconds(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        var sec = seconds
        if seconds < 0 { sec = 0 }
        if seconds > Int(duration) { sec = Int(duration) }
        return (hours: sec / 3600, minutes: (sec % 3600) / 60, seconds: (sec % 3600) % 60)
    }
}
