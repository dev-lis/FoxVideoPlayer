//
//  FVPProgressPreviewImageView.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 29.03.2022.
//

import UIKit

public class FVPProgressPreviewImageView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        
        backgroundColor = .white
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
        ])
    }
}

