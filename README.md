# FoxVideoPlayer

[![Platforms](https://img.shields.io/badge/Platforms-iOS-blue?style=flat-square)](https://developer.apple.com/macOS)
[![iOS](https://img.shields.io/badge/iOS-14.0-blue.svg)](https://developer.apple.com/iOS)
[![Version](https://img.shields.io/cocoapods/v/FoxVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/FoxVideoPlayer)
[![License](https://img.shields.io/badge/licenses-MIT-red.svg)](https://opensource.org/licenses/MIT) 

## Installation

FoxVideoPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FoxVideoPlayer', '~> 1.0.2'
```

## Description
Fox Video Player consists of few components:

- **FVPVideoPlayer** - main part of player whitch should implement playback video.
- **FVPControls** - contains elements to controll playback video:
    - **startPlay/replay**
    - **play/pause**
    - **backward**
    - **forward**
- **FVPProgressBar** - element allows observe and rewind video. This elemet also contains button for activate full screen mode.
- **FVPProgressSlider** - part of `FVPProgressBar`
- **FVPPlaceholder** - if somthing went wrong, you should show some message with information, and button for try to reload.
- **FVPLoader** - loading indicator
- **FVPFullScreen** - component for inplement full screen mode player.

You can customising any player components. Just create instance it with settings, where you can update needed values, and set new one to FVPDependency.. Each component has settings property:

- **FVPVideoPlayerSettings**
- **FVPControlsSettings**
- **FVPProgressBarSettings**
- **FVPProgressBarSliderSettings**
- **FVPPlaceholderSettings**
- **FVPLoaderSettings**

You also can create your own component. You just need implement protocol for any or all.

## Usages

```swift
let dependency = FVPDependency()
let playerController = FVPController(dependency: dependency)
let playerViewController = playerController.getVideoPlayer()
        
addChild(playerViewController)
playerViewController.didMove(toParent: self)
view.addSubview(playerViewController.view)

NSLayoutConstraint.activate([
    playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
    playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    playerViewController.view.heightAnchor.constraint(equalToConstant: playerViewController.height)

])
        
if let url = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") {
    playerViewController.setup(with: url)
}
```

## Settings
You can also customize the appearance of the player.

## Author

dev-lis, mr.aleksandr.lis@gmail.com

## License

FoxVideoPlayer is available under the MIT license. See the LICENSE file for more info.
