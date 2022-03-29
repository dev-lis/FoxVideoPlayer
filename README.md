# FoxVideoPlayer

[![Platforms](https://img.shields.io/badge/Platforms-iOS-blue?style=flat-square)](https://developer.apple.com/macOS)
[![iOS](https://img.shields.io/badge/iOS-14.0-blue.svg)](https://developer.apple.com/iOS)
[![Version](https://img.shields.io/cocoapods/v/FoxVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/FoxVideoPlayer)
[![License](https://img.shields.io/badge/licenses-MIT-red.svg)](https://opensource.org/licenses/MIT) 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

FoxVideoPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FoxVideoPlayer'
```

## Usages
```swift
if let url = URL(string: <YOUR-URL>) {
    let playerViewController = FoxVideoPlayerViewController()
    playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
    playerViewController.setup(with: url)
    
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
```

## Author

dev-lis, mr.aleksandr.lis@gmail.com

## License

FoxVideoPlayer is available under the MIT license. See the LICENSE file for more info.
