//
//  FVPProgressSliderControl.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

class FVPProgressSliderControl: UIControl {
    private lazy var lineLayer: FVPProgressBarLineLayer = {
        let layer = FVPProgressBarLineLayer()
        layer.backgroundColor = settings.color.sliderBackground.cgColor
        layer.cornerRadius = settings.size.sliderHeight / 2
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
        layer.frame.size = CGSize(width: settings.size.pinDefaultSize, height: settings.size.pinDefaultSize)
        layer.cornerRadius = settings.size.pinDefaultSize / 2
        return layer
    }()

    private lazy var previewImageView: FVPProgressPreviewImageView = {
        let view = FVPProgressPreviewImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    private lazy var previewTimeLabel: UILabel = {
        let label = UILabel()
        label.font = settings.font.previewTime
        label.textColor = settings.color.previewTime
        label.textAlignment = .center
        label.alpha = 0
        label.text = " "
        return label
    }()
    
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
        let inset = pinContainerLayer.bounds.width / 4 + (isVisible ? 0 : settings.size.sideInsetsOnShownState)
        return currentPinPosition! > lineLayer.value + inset - (isVisible ? 0 : settings.size.sideInsetsOnShownState * 2) ||
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
    
    private var previewImageViewY: CGFloat {
        return -previewTimeLabel.frame.height - previewImageView.frame.height - settings.size.previewLabelBottomInset - settings.size.previewImageBottomInset
    }
    
    public weak var delegate: FVPProgressSliderDelegate?
    
    private let settings: FVPProgressBarSliderSettings
    
    init(settings: FVPProgressBarSliderSettings) {
        self.settings = settings
        super.init(frame: .zero)
        self.isExclusiveTouch = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard isAnimationCompleted else { return }
        
        updateLine()
        updatePin()
    }
    
    private func updateLine() {
        let lineX: CGFloat = isVisible ? settings.size.sideInsetsOnShownState : 0
        let lineWidth = isVisible ? frame.size.width - settings.size.sideInsetsOnShownState * 2 : frame.size.width

        lineLayer.frame = CGRect(
            x: lineX,
            y: frame.height / 2 - settings.size.sliderHeight / 2,
            width: lineWidth,
            height: settings.size.sliderHeight
        )
    }
    
    private func updatePin() {
        guard !isSeeking else { return }
        
        if currentPinPosition == nil { currentPinPosition = settings.size.sideInsetsOnShownState - frame.height / 2 }
        
        let inset = isVisible
            ? frame.height
            : 0
        var curPinPosition = currentProgress * (frame.width - inset)
        if !isVisible { curPinPosition -= settings.size.sideInsetsOnShownState }

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
            ? isIncreased ? settings.size.pinIncreasedSize : settings.size.pinDefaultSize
            : isIncreased ? settings.size.pinIncreasedSize : 0
        pinLayer.frame = CGRect(
            x: frame.height / 2 - pinLayer.frame.width / 2,
            y: pinContainerLayer.frame.height / 2 - pinLayer.frame.height / 2,
            width: pinSide,
            height: pinSide
        )

        let leftInset = FVPScreen.SafeArea.left + 8
        let currentInfoInset = currentPinPosition! + pinContainerLayer.frame.width / 2
        let currentTimeX = currentInfoInset - previewTimeLabel.frame.width / 2 > leftInset
        ?  currentInfoInset - previewTimeLabel.frame.width / 2
        : leftInset
        previewTimeLabel.sizeToFit()
        previewTimeLabel.frame.origin = CGPoint(
            x: currentTimeX,
            y: -previewTimeLabel.frame.height - settings.size.previewLabelBottomInset
        )
        
        let currentPreviewX = currentInfoInset - previewImageView.frame.width / 2 > leftInset
        ? currentInfoInset - previewImageView.frame.width / 2
        : leftInset
        previewImageView.frame.origin = CGPoint(
            x: currentPreviewX,
            y: previewImageViewY
        )
    }
    
    private func setupUI() {
        addSubview(previewTimeLabel)
        addSubview(previewImageView)
        
        let inset = FVPScreen.SafeArea.left + 8
        previewTimeLabel.frame.origin.x = inset
        previewImageView.frame.origin.x = inset

        layer.addSublayer(lineLayer)
        layer.addSublayer(pinContainerLayer)
        pinContainerLayer.setNeedsDisplay()
        pinLayer.setNeedsDisplay()
    }
}

// MARK: FoxVideoPlayerProgressSlider

extension FVPProgressSliderControl: FVPProgressSlider {
    
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
            self.previewImageView.frame.origin.y = self.previewImageViewY
        }
    }
    
    public func updateLayout() {
        layoutSubviews()
    }
    
    public func showAnimation() {
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
            self.lineLayer.cornerRadius = self.settings.size.sliderHeight / 2
        }

        var animations = [CABasicAnimation]()

        let positionAnimation = CABasicAnimation(keyPath: "bounds")
        positionAnimation.fromValue = lineLayer.frame
        positionAnimation.toValue = CGRect(
            x: settings.size.sideInsetsOnShownState,
            y: lineLayer.frame.origin.y,
            width: frame.width - settings.size.sideInsetsOnShownState * 2,
            height: lineLayer.frame.height
        )
        animations.append(positionAnimation)

        let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        cornerAnimation.fromValue = 0
        cornerAnimation.toValue = settings.size.sliderHeight / 2

        animations.append(cornerAnimation)

        let group = CAAnimationGroup()
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.duration = settings.duration.animation
        group.animations = animations
        lineLayer.add(group, forKey: nil)

        let pinAnimation = CABasicAnimation(keyPath: "bounds")
        pinAnimation.fillMode = .forwards
        pinAnimation.isRemovedOnCompletion = false
        pinAnimation.duration = settings.duration.animation
        pinAnimation.fromValue = pinLayer.frame
        pinAnimation.toValue = CGRect(
            x: currentPinPosition!,
            y: pinContainerLayer.frame.height / 2 - settings.size.pinDefaultSize / 2,
            width: settings.size.pinDefaultSize,
            height: settings.size.pinDefaultSize
        )
        pinLayer.add(pinAnimation, forKey: nil)

        CATransaction.commit()
    }

    public func hideAnimation() {
        guard isAnimationCompleted else { return }

        isAnimationCompleted = false
        
        currentPinPosition = currentProgress * frame.width - settings.size.sideInsetsOnShownState
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
        corrnerAnimation.fromValue = settings.size.sliderHeight / 2
        corrnerAnimation.toValue = 0

        animations.append(corrnerAnimation)

        let group = CAAnimationGroup()
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.duration = settings.duration.animation
        group.animations = animations
        lineLayer.add(group, forKey: nil)

        let pinAnimation = CABasicAnimation(keyPath: "bounds")
        pinAnimation.fillMode = .forwards
        pinAnimation.isRemovedOnCompletion = false
        pinAnimation.duration = settings.duration.animation
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

extension FVPProgressSliderControl {
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
            let position = lineLayer.value + (isVisible ? settings.size.sideInsetsOnShownState : 0)
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

private extension FVPProgressSliderControl {
    func increasePin() {
        pinLayer.frame = CGRect(
            x: pinContainerLayer.frame.width / 2 - settings.size.pinIncreasedSize / 2,
            y: pinContainerLayer.frame.height / 2 - settings.size.pinIncreasedSize / 2,
            width: settings.size.pinIncreasedSize,
            height: settings.size.pinIncreasedSize
        )
        pinLayer.cornerRadius = 10

        isIncreased = true
    }

    func decreasePin() {
        pinLayer.frame = CGRect(
            x: pinContainerLayer.frame.width / 2 - settings.size.pinDefaultSize / 2,
            y: pinContainerLayer.frame.height / 2 - settings.size.pinDefaultSize / 2,
            width: isVisible ? settings.size.pinDefaultSize : 0,
            height: isVisible ? settings.size.pinDefaultSize : 0
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

private extension FVPProgressSliderControl {
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
        UIView.animate(withDuration: settings.duration.animation) {
            self.previewTimeLabel.alpha = 1
            self.previewImageView.alpha = 1
        }
    }
    
    func hideInfo() {
        UIView.animate(withDuration: settings.duration.animation) {
            self.previewTimeLabel.alpha = 0
            self.previewImageView.alpha = 0
        }
    }
    
    private func vibrate() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: Time

private extension FVPProgressSliderControl {
    func updateTime(for position: CGFloat) {
        currentTime = time(for: position)
        previewTime = currentTime
        let timePart = secondsToHoursMinutesSeconds(seconds: Int(currentTime))
        previewTimeLabel.text = String(timePart.minutes) + ":" + getTimeString(timeValue: timePart.seconds)
        previewTimeLabel.sizeToFit()
        
        let leftInset = FVPScreen.SafeArea.left + 8
        let rightInset = frame.width - FVPScreen.SafeArea.right - 8

        if position - previewTimeLabel.frame.width / 2 < leftInset {
            previewTimeLabel.frame.origin.x = leftInset
        } else if position + previewTimeLabel.frame.width / 2 >= rightInset {
            previewTimeLabel.frame.origin.x = rightInset - previewTimeLabel.frame.width
        } else {
            previewTimeLabel.center.x = position
        }
    }
    
    func updatePreview(for position: CGFloat) {
        let leftInset = FVPScreen.SafeArea.left + 8
        let rightInset = frame.width - FVPScreen.SafeArea.right - 8

        if position - previewImageView.frame.width / 2 < leftInset {
            previewImageView.frame.origin.x = leftInset
        } else if position + previewImageView.frame.width / 2 >= rightInset {
            previewImageView.frame.origin.x = rightInset - previewImageView.frame.width
        } else {
            previewImageView.center.x = position
        }
    }
    
    func time(for position: CGFloat) -> CGFloat {
        let insetPoint: CGFloat = isVisible ? settings.size.sideInsetsOnShownState : 0
        let insetWidth: CGFloat = isVisible ? settings.size.sideInsetsOnShownState * 2 : 0
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
