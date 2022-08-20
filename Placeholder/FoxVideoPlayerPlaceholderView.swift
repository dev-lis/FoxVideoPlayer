//
//  FoxVideoPlayerPlaceholderView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 21.08.2022.
//

import Foundation

public class FoxVideoPlayerPlaceholderView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Repeat", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    public weak var delegate: FoxVideoPlayerPlaceholderDelegate?
    
    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        isHidden = true
        
        addSubview(titleLabel)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            
            button.topAnchor.constraint(equalTo: centerYAnchor, constant: 8),
            button.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    @objc private func didTapButton() {
        delegate?.repeate(self)
    }
}

// MARK: FoxVideoPlayerPlaceholder

extension FoxVideoPlayerPlaceholderView: FoxVideoPlayerPlaceholder {
    
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
