//
//  FoxFullScreenVideoPlayerViewController.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 28.03.2022.
//

import UIKit

public protocol FoxFullScreenVideoPlayerViewControllerDelegate: AnyObject {
    func didHideFullScreen(_ controller: FoxFullScreenVideoPlayerViewController)
}

public class FoxFullScreenVideoPlayerViewController: UIViewController {
    
    private var playerTopConstraint: NSLayoutConstraint!
    private var playerBottomConstraint: NSLayoutConstraint!
    private var playerHeightConstraint: NSLayoutConstraint!
    
    public enum Source {
        case button
        case rotate
    }
    
    private var startPlayerHeight: CGFloat {
        UIScreen.main.bounds.height - UIScreen.main.bounds.height * 9 / 16 - startPlayerOriginY
    }
    
    private let startPlayerOriginY: CGFloat
    
    public weak var delegate: FoxFullScreenVideoPlayerViewControllerDelegate?
    
    private let playerView: UIView
    private let source: Source
    
    public init(playerView: UIView, source: Source) {
        self.playerView = playerView
        self.source = source
        self.startPlayerOriginY = playerView.frame.origin.y
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            portraitOrientation()
            dismiss()
        } else {
            landscapeOrientation()
            view.layoutIfNeeded()
        }
    }
    
    public func close() {
        rotate(to: .portrait)
    }
    
    private func start() {
        switch source {
        case .button:
            rotate(to: .landscapeRight)
        case .rotate:
            landscapeOrientation()
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func dismiss() {
        dismiss(animated: false) {
            self.playerView.removeFromSuperview()
            self.delegate?.didHideFullScreen(self)
        }
    }
    
    private func rotate(to orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    private func portraitOrientation() {
        playerTopConstraint.constant = startPlayerOriginY
        playerBottomConstraint.constant = startPlayerHeight
    }
    
    private func landscapeOrientation() {
        playerTopConstraint.constant = 0
        playerBottomConstraint.constant = 0
    }
    
    private func setupUI() {
        view.addSubview(playerView)
        
        let inset: CGFloat = UIWindow.isLandscape ? 0 : startPlayerOriginY
        
        playerTopConstraint = playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inset)
        playerBottomConstraint = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: startPlayerHeight)
        
        NSLayoutConstraint.activate([
            playerTopConstraint,
            playerBottomConstraint,
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
