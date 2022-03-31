#
# Be sure to run `pod lib lint FoxVideoPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FoxVideoPlayer'
  s.version          = '0.1.1'
  s.summary          = 'Customizable video player'
  s.description      = 'You can easily and quickly integrate a video player into your project. You can use all player or some of its components. The player summer insists.'

  s.homepage         = 'https://github.com/dev-lis/FoxVideoPlayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dev-lis' => 'mr.aleksandr.lis@gmail.com' }
  s.source           = { :git => 'https://github.com/dev-lis/FoxVideoPlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions = '5.0'

  s.source_files = 'FoxVideoPlayer/Sources/**/*.{h,m,swift}'
  
end
