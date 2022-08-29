//
//  FVPSeekButton.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

class FVPSeekButton: UIView {
    private lazy var seekButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = .white
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        return button
    }()

    private lazy var seekImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        return imageView
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var seekContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var seekLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    var didTap: ((Int) -> Void)?
    
    private var multiplier: Int {
        switch direction {
        case .forward: return 1
        case .backward: return -1
        }
    }
    
    public var seekImage: UIImage? {
        didSet {
            seekImageView.image = seekImage
        }
    }
    
    public var color: UIColor? {
        didSet {
            seekImageView.tintColor = color
        }
    }

    private var resetSeekCounerItem: DispatchWorkItem?
    private var singleTap = true

    private var currentSeek: Int {
        didSet {
//            setSeekCounter()
        }
    }
    
    enum Direction {
        case forward
        case backward
    }

    private var direction: Direction

    init(direction: Direction) {
        self.direction = direction
        self.currentSeek = abs(5)
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(seekLabel)
        addSubview(seekContainerView)
        addSubview(seekButton)
        seekContainerView.addSubview(seekImageView)
        NSLayoutConstraint.activate([
            seekContainerView.topAnchor.constraint(equalTo: topAnchor),
            seekContainerView.leftAnchor.constraint(equalTo: leftAnchor),
            seekContainerView.rightAnchor.constraint(equalTo: rightAnchor),
            seekContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            seekLabel.centerXAnchor.constraint(equalTo: seekContainerView.centerXAnchor),
            seekLabel.centerYAnchor.constraint(equalTo: seekContainerView.centerYAnchor),
            seekLabel.widthAnchor.constraint(equalToConstant: 10),

            seekImageView.centerXAnchor.constraint(equalTo: seekContainerView.centerXAnchor, constant: 0),
            seekImageView.centerYAnchor.constraint(equalTo: seekContainerView.centerYAnchor, constant: 0),

            seekButton.topAnchor.constraint(equalTo: seekContainerView.topAnchor),
            seekButton.leftAnchor.constraint(equalTo: seekContainerView.leftAnchor),
            seekButton.rightAnchor.constraint(equalTo: seekContainerView.rightAnchor),
            seekButton.bottomAnchor.constraint(equalTo: seekContainerView.bottomAnchor)
        ])

//        setSeekCounter()
    }

    func setVisible(_ visible: Bool) {
        alpha = visible ? 1 : 0
    }

    func seekAnimation() {
        touchUpInside()
        guard alpha == 0 else { return }
        UIView.animateKeyframes(withDuration: 0.6,
                                delay: 0,
                                options: .calculationModeCubicPaced) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                self.alpha = 0.6
            }

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.6) {
                self.alpha = 0.0
            }
        }
    }

//    private func setSeekCounter() {
//        seekLabel.text = String(currentSeek)
//        if currentSeek < 10 {
//            seekLabel.font = UIFont.systemFont(ofSize: size * 0.23)
//        } else if currentSeek < 100 {
//            seekLabel.font = UIFont.systemFont(ofSize: size * 0.15)
//        } else {
//            seekLabel.font = UIFont.systemFont(ofSize: size * 0.10)
//        }
//    }

    @objc private func touchUpInside() {
        didTap?(5 * multiplier)

        if !singleTap { currentSeek += abs(5) }
        resetSeekCounerItem?.cancel()
        resetSeekCounerItem = DispatchWorkItem {
            self.currentSeek = abs(5)
            self.singleTap = true
        }
        UIView.animateKeyframes(withDuration: 0.5,
                                delay: 0,
                                options: .calculationModeCubicPaced) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                let rotationAngle = .pi * 0.6 * CGFloat(self.multiplier)
                self.seekContainerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
                self.seekLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }

            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.5) {
                self.seekContainerView.transform = .identity
                self.seekLabel.transform = .identity
            }
        } completion: { _ in
            guard let item = self.resetSeekCounerItem else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: item)
        }
        singleTap = false
    }
}

