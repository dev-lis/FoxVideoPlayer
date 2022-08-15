//
//  FoxVideoPlayerLoaderView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 14.08.2022.
//

import Foundation

class FoxVideoPlayerLoaderView: UIView {
    private lazy var loadIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: settings.style)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = settings.color
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()
    
    private var centerXConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    
    private var didLayout = false
    
    private let settings: FoxVideoPlayerLoaderSettings
    
    init(settings: FoxVideoPlayerLoaderSettings) {
        self.settings = settings
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePositionIfNeed()
    }
    
    private func setupUI() {
        addSubview(loadIndicator)
        
        centerXConstraint = loadIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerYConstraint = loadIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        centerXConstraint.isActive = true
        centerYConstraint.isActive = true
    }
    
    private func updatePositionIfNeed() {
        guard !didLayout else { return }
        didLayout = true
        
        guard
            let width = superview?.bounds.width,
            let height = superview?.bounds.height
        else { return }
        
        if width / 2 - settings.size.centerXInset <= 0 {
            centerXConstraint.constant = loadIndicator.bounds.width / 2 + 8 - width / 2
        } else if settings.size.centerXInset - width / 2 >= 0 {
            centerXConstraint.constant = width / 2 - loadIndicator.bounds.width / 2 - 8
        } else {
            centerXConstraint.constant = settings.size.centerXInset
        }
        
        if height / 2 - settings.size.centerYInset <= 0 {
            centerYConstraint.constant = loadIndicator.bounds.height / 2 + 8 - height / 2
        } else if settings.size.centerYInset - height / 2 >= 0 {
            centerYConstraint.constant = height / 2 - loadIndicator.bounds.height / 2 - 8
        } else {
            centerYConstraint.constant = settings.size.centerYInset
        }
    }
}

// MARK: FoxVideoPlayerLoader

extension FoxVideoPlayerLoaderView: FoxVideoPlayerLoader {
    
    func add(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func start() {
        loadIndicator.startAnimating()
    }
    
    func stop() {
        loadIndicator.stopAnimating()
    }
}
