//
//  ViewController.swift
//  FoxVideoPlayer
//
//  Created by dev-lis on 03/29/2022.
//  Copyright (c) 2022 dev-lis. All rights reserved.
//

import UIKit
import FoxVideoPlayer

class ViewController: UIViewController {
    
    private lazy var playerViewController: FoxVideoPlayerViewController = {
        let sliderSettings = FoxVideoPlayerProgressBarSliderSettings()
        let progressBarSettings = FoxVideoPlayerProgressBarSettings(sliderSettings: sliderSettings)
        let controller = FoxVideoPlayerViewController(progressBarSettings: progressBarSettings)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let url = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") {
            playerViewController.setup(with: url)
        }
    }

    func setupUI() {
        view.backgroundColor = .white
        
        addChild(playerViewController)
        playerViewController.didMove(toParent: self)
        view.addSubview(playerViewController.view)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerViewController.view.heightAnchor.constraint(equalToConstant: playerViewController.height)

        ])
    }
}

