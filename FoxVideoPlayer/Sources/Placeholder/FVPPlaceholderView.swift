//
//  FVPPlaceholderView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.08.2022.
//

import Foundation

public class FVPPlaceholderView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = settings.text.error
        label.textAlignment = .center
        label.textColor = settings.color.textColor
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(settings.text.button, for: .normal)
        button.setTitleColor(settings.color.buttonTextColor, for: .normal)
        button.setImage(settings.image.button, for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    public weak var delegate: FVPPlaceholderDelegate?
    
    private let settings: FVPPlaceholderSettings
    
    public init(settings: FVPPlaceholderSettings) {
        self.settings = settings
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = settings.color.background
        isHidden = true
        
        addSubview(titleLabel)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: settings.size.textCenterYInset),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: settings.size.textCenterXInset),
            
            button.topAnchor.constraint(equalTo: centerYAnchor, constant: settings.size.buttonCenterYInset),
            button.centerXAnchor.constraint(equalTo: centerXAnchor, constant: settings.size.butoonCenterXInset)
        ])
    }
    
    @objc private func didTapButton() {
        delegate?.repeate(self)
    }
}

// MARK: FoxVideoPlayerPlaceholder

extension FVPPlaceholderView: FVPPlaceholder {
    
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
    
    public func show() {
        isHidden = false
    }
    
    public func hide() {
        isHidden = true
    }
}
