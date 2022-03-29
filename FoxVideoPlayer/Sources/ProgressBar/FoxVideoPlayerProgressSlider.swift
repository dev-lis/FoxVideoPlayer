//
//  FoxVideoPlayerProgressSlider.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

class FoxVideoPlayerProgressSlider: UIControl {
    private lazy var lineLayer: FoxVideoPlayerProgressBarLineLayer = {
        let layer = FoxVideoPlayerProgressBarLineLayer()
        layer.fillColor = settings.sliderFillColor
        layer.backgroundColor = settings.sliderBackgroundColor.cgColor
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
        layer.backgroundColor = settings.sliderFillColor.cgColor
        layer.frame.size = CGSize(
            width: pinDefaultSize,
            height: pinDefaultSize
        )
        layer.cornerRadius = pinDefaultSize / 2
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

    public var movingOnRaised: ((Bool) -> Void)?
    public var movingOnHidden: ((Bool) -> Void)?
    public var time: ((CGFloat) -> Void)?
    public var imageForTime: ((CGFloat) -> Void)?

    public var duration: CGFloat = 0
    public var currentTime: CGFloat = 0

    public var animateDuration: TimeInterval = 0.2
    public var sliderTopInset: CGFloat {
        lineLayer.frame.maxY
    }
    
    private var timer: Timer?

    private var sideInset: CGFloat {
        settings.sideInsetsOnShownState
    }
    
    private var pinDefaultSize: CGFloat {
        settings.pinDefaultSize
    }
    
    private var pinIncreasedSize: CGFloat {
        settings.pinIncreasedSize
    }
    
    private var isRoundedCornersSlider: Bool {
        settings.isRoundedCornersSlider && settings.sideInsetsOnShownState > 0
    }
    
    private var currentPinContainerX: CGFloat {
        currentProgress * lineLayer.frame.width - frame.height / 2 + (isVisible ? sideInset : 0)
    }
    
    private var pinContainerSize: CGFloat {
        frame.height
    }
    
    private var previewTime: CGFloat = 0
    private var currentPinPosition: CGFloat?
    private var isAnimationCompleted = true
    private var isVisible = false
    private var isIncreased = false
    private var isSeeking = false
    private var isMagnetized = true
    private var isEnableUpdateImage = false
    
    private var isMagnetedZone: Bool {
        currentPinPosition! > lineLayer.value - pinIncreasedSize / 3 - (isVisible ? 0 : sideInset)
        && currentPinPosition! < lineLayer.value + pinIncreasedSize / 3 - (isVisible ? 0 : sideInset)
    }

    private var isMovingOnVisible: Bool = false {
        didSet {
            movingOnRaised?(isMovingOnVisible)
        }
    }
    
    private var isMovingOnUnvisible: Bool = false {
        didSet {
            movingOnHidden?(isMovingOnUnvisible)
        }
    }

    private var currentProgress: CGFloat = 0 {
        didSet {
            lineLayer.progress = currentProgress
            if !isMovingOnVisible {
                layoutSubviews()
            }
        }
    }
    
    private let settings: FoxVideoPlayerProgressBarSliderSettings

    init(settings: FoxVideoPlayerProgressBarSliderSettings) {
        self.settings = settings
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ progress: CGFloat) {
        currentProgress = progress
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isAnimationCompleted else { return }
        
        updateLine()
        updatePin()
    }
    
    private func updateLine() {
        let lineX: CGFloat = isVisible ? sideInset : 0
        let lineWidth = isVisible
        ? frame.size.width - sideInset * 2
        : frame.size.width

        lineLayer.frame = CGRect(
            x: lineX,
            y: frame.height / 2 - 2,
            width: lineWidth,
            height: 4
        )
    }
    
    private func updatePin() {
        guard !isSeeking else { return }
        
        pinContainerLayer.frame = CGRect(
            x: currentPinContainerX,
            y: 0,
            width: frame.height,
            height: frame.height
        )

        let pinSide: CGFloat = isVisible
            ? isIncreased ? pinIncreasedSize : pinDefaultSize
            : isIncreased ? pinIncreasedSize : 0
        pinLayer.frame = CGRect(
            x: pinContainerSize / 2 - pinLayer.frame.width / 2,
            y: pinContainerLayer.frame.height / 2 - pinLayer.frame.height / 2,
            width: pinSide,
            height: pinSide
        )

        let leftInset = FoxScreen.SafeArea.left + 8
        let currentInfoInset = currentPinContainerX + pinContainerLayer.frame.width / 2
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
            y: -currentTimeLabel.frame.height - previewImageView.frame.height - sideInset
        )
    }
    
    func didUpdateTime() {
        isSeeking = false
    }
    
    func setPreviewImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.previewImageView.isHidden = image == nil
            self.previewImageView.image = image
        }
    }

    func setPreviewImageSize(_ size: CGSize) {
        DispatchQueue.main.async {
            self.previewImageView.frame.size = size
            self.previewImageView.frame.origin.y = -self.currentTimeLabel.frame.height - self.previewImageView.frame.height - self.sideInset
        }
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

// MARK: Animation

extension FoxVideoPlayerProgressSlider {
    func showAnimation() {
        guard isAnimationCompleted else { return }
        
        isAnimationCompleted = false
        isVisible = true

        let x = currentProgress * (frame.width - sideInset * 2) - pinContainerSize / 2 + (isVisible ? sideInset : 0)
        pinContainerLayer.frame = CGRect(
            x: x,
            y: 0,
            width: pinContainerSize,
            height: pinContainerSize
        )

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isAnimationCompleted = true
            self.layoutSubviews()
            self.lineLayer.removeAllAnimations()
            self.pinLayer.removeAllAnimations()
            self.lineLayer.cornerRadius = self.isRoundedCornersSlider ? 2 : 0
        }

        var animations = [CABasicAnimation]()

        let positionAnimation = CABasicAnimation(keyPath: "bounds")
        positionAnimation.fromValue = lineLayer.frame
        positionAnimation.toValue = CGRect(
            x: sideInset,
            y: lineLayer.frame.origin.y,
            width: frame.width - sideInset * 2,
            height: lineLayer.frame.height
        )
        animations.append(positionAnimation)

        if isRoundedCornersSlider {
            let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
            cornerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
            cornerAnimation.fromValue = 0
            cornerAnimation.toValue = 2

            animations.append(cornerAnimation)
        }

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
            x: currentPinContainerX,
            y: pinContainerLayer.frame.height / 2 - pinDefaultSize / 2,
            width: pinDefaultSize,
            height: pinDefaultSize
        )
        pinLayer.add(pinAnimation, forKey: nil)

        CATransaction.commit()
    }

    func hideAnimation() {
        guard isAnimationCompleted else { return }

        isAnimationCompleted = false

        pinContainerLayer.frame = CGRect(
            x: currentPinContainerX,
            y: 0,
            width: pinContainerSize,
            height: pinContainerSize
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

        if isRoundedCornersSlider {
            let corrnerAnimation = CABasicAnimation(keyPath: "cornerRadius")
            corrnerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
            corrnerAnimation.fromValue = 2
            corrnerAnimation.toValue = 0

            animations.append(corrnerAnimation)
        }

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
            y: pinContainerLayer.frame.height / 2,
            width: 0,
            height: 0
        )
        pinLayer.add(pinAnimation, forKey: nil)

        CATransaction.commit()
    }
}

extension FoxVideoPlayerProgressSlider {
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
        
        currentPinPosition = point.x - sideInset

        if isMagnetedZone {
            guard !isMagnetized else { return true }
            let position = lineLayer.value + (isVisible ? sideInset : 0)
            update(x: position)
            isMagnetized = true
            vibrate()
        } else {
            update(x: point.x)
            isMagnetized = false
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
            didUpdateTime()
        } else {
            time?(currentTime)
        }
        
        isMagnetized = true

        hideInfo()
        
        stopUpdatePreviewTimer()
    }
}

// MARK: Private

private extension FoxVideoPlayerProgressSlider {
    func increasePin() {
        pinLayer.frame = CGRect(
            x: pinContainerLayer.frame.width / 2 - pinIncreasedSize / 2,
            y: pinContainerLayer.frame.height / 2 - pinIncreasedSize / 2,
            width: pinIncreasedSize,
            height: pinIncreasedSize
        )
        pinLayer.cornerRadius = pinIncreasedSize / 2

        isIncreased = true
    }

    func decreasePin() {
        pinLayer.frame = CGRect(
            x: pinContainerLayer.frame.width / 2 - pinDefaultSize / 2,
            y: pinContainerLayer.frame.height / 2 - pinDefaultSize / 2,
            width: isVisible ? pinDefaultSize : 0,
            height: isVisible ? pinDefaultSize : 0
        )
        pinLayer.cornerRadius = pinDefaultSize / 2

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

private extension FoxVideoPlayerProgressSlider {
    func update(x: CGFloat) {
        updatePinPosition(for: x)
        updateTime(for: x)
        updatePreview(for: x)
    }
    
    func startUpdatePreviewTimer() {
        imageForTime?(previewTime)
        stopUpdatePreviewTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let previewTime = self?.previewTime else { return }
            self?.imageForTime?(previewTime)
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

private extension FoxVideoPlayerProgressSlider {
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
        let insetPoint: CGFloat = isVisible ? sideInset : 0
        let insetWidth: CGFloat = isVisible ? sideInset * 2 : 0
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
