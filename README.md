# FoxVideoPlayer

[![Platforms](https://img.shields.io/badge/Platforms-iOS-blue?style=flat-square)](https://developer.apple.com/macOS)
[![iOS](https://img.shields.io/badge/iOS-14.0-blue.svg)](https://developer.apple.com/iOS)
[![Version](https://img.shields.io/cocoapods/v/FoxVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/FoxVideoPlayer)
[![License](https://img.shields.io/badge/licenses-MIT-red.svg)](https://opensource.org/licenses/MIT) 

## Installation

FoxVideoPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FoxVideoPlayer', '~> 0.1.1'
```

## Usages
```swift
if let url = URL(string: <YOUR-URL>) {
    let sliderSettings = FoxVideoPlayerProgressBarSliderSettings()
    let progressBarSettings = FoxVideoPlayerProgressBarSettings(sliderSettings: sliderSettings)
    let controller = FoxVideoPlayerViewController(progressBarSettings: progressBarSettings)
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

## Customization
You can also customize the appearance of the player.

### FoxVideoPlayerProgressBarSliderSettings
```swift
/// Height of progress slider line. Default value is 4.0.
var sliderHeight: CGFloat
/// Side insets of progress slider on shown state. Default value is 16.0.
var sideInsetsOnShownState: CGFloat
/// Size of progress pin on default state. Default value is 12.0.
var pinDefaultSize: CGFloat
/// Size of progress pin on tap and swipe. Default value is 20.0.
var pinIncreasedSize: CGFloat
/// Slider line color. Default value is UIColor.white.withAlphaComponent(0.44).
var sliderBackgroundColor: UIColor
/// Slider progress line color. Default value is UIColor.systemBlue.
var sliderFillColor: UIColor
/// Color of current time label which shown on tap and swipe. Default value is UIColor.white.
var previewTimeLabelColor: UIColor
/// Font of current time label which shown on tap and swipe. Default value is. UIFont.systemFont(ofSize: 18, weight: .medium)
var previewTimeLabelFont: UIFont
/// Duration of the animation show preview time label. Default value is 0.2.
var previewAnimateDuration: TimeInterval
/// Rounded corners slider line on shown state.  Default value is true.
var isRoundedCornersSlider: Bool
/// Enable vibrate on tap slider. Default value is true.
var isEnableVibrate: Bool
```

### FoxVideoPlayerProgressBarSettings
```swift
/// Height of progress bar. Default value is 66.0.
var barHeight: CGFloat
/// Left inset of timer. Default value is 24.0.
var timerLeftInset: CGFloat
/// Right inset os stack buttons. Default value is 24.0.
var buttonsStackRightInset: CGFloat
/// Timer color. Default value is UIColor.white.
var timerLabelColor: UIColor
/// Timer font. Default value is UIFont.systemFont(ofSize: 14, weight: .semibold).
var timerLabelFont: UIFont
/// Slider progress line color. Default value is 0.2.
var animateDuration: TimeInterval
/// Settings of progress slider.
var sliderSettings: FoxVideoPlayerProgressBarSliderSettings
```

## Author

dev-lis, mr.aleksandr.lis@gmail.com

## License

FoxVideoPlayer is available under the MIT license. See the LICENSE file for more info.
