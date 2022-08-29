//
//  FoxVideoPlayerPlaceholderSettings.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 29.08.2022.
//

import Foundation

public struct FoxVideoPlayerPlaceholderSettings {
    
    let text: Text
    let image: Image
    let color: Color
    let size: Size
    
    public init(text: Text = Text(),
                image: Image = Image(),
                color: Color = Color(),
                size: Size = Size()) {
        self.text = text
        self.image = image
        self.color = color
        self.size = size
    }
}

extension FoxVideoPlayerPlaceholderSettings {
    public struct Text {
        let error: String?
        let button: String?
        
        public init(error: String? = nil,
                    button: String? = nil) {
            self.error = error ?? "Something went wrong"
            self.button = button ?? "Repeat"
        }
    }
}

extension FoxVideoPlayerPlaceholderSettings {
    public struct Image {
        let button: UIImage?
        
        public init(button: UIImage? = nil) {
            self.button = button
        }
    }
}

extension FoxVideoPlayerPlaceholderSettings {
    public struct Color {
        let background: UIColor
        let textColor: UIColor
        let buttonTextColor: UIColor
        
        public init(background: UIColor = .black,
                    textColor: UIColor = .white,
                    buttonTextColor: UIColor = .white) {
            self.background = background
            self.textColor = textColor
            self.buttonTextColor = buttonTextColor
        }
    }
}

extension FoxVideoPlayerPlaceholderSettings {
    public struct Size {
        let textCenterXInset: CGFloat
        let textCenterYInset: CGFloat
        let butoonCenterXInset: CGFloat
        let buttonCenterYInset: CGFloat
        
        public init(textCenterXInset: CGFloat = 0.0,
                    textCenterYInset: CGFloat = -8.0,
                    butoonCenterXInset: CGFloat = 0.0,
                    buttonCenterYInset: CGFloat = 8.0) {
            self.textCenterXInset = textCenterXInset
            self.textCenterYInset = textCenterYInset
            self.butoonCenterXInset = butoonCenterXInset
            self.buttonCenterYInset = buttonCenterYInset
        }
    }
}
