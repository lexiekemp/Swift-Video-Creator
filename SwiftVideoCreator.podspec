#
# Be sure to run `pod lib lint SwiftVideoCreator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftVideoCreator'
  s.version          = '0.1.0'
  s.summary          = 'A tool to create a video composition using a video, image, and audio'

  s.description      = <<-DESC
'Create an m4v video from a video on top of an image and audio. Choose the dimensions, position, and opacity of the video, and image. Choose the dimensions of the composition.
                       DESC

  s.homepage         = 'https://github.com/lexiekemp/Swift-Video-Creator'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lexie Kemp' => 'lexie.kd@gmail.com' }
  s.source           = { :git => 'https://github.com/lexiekemp/Swift-Video-Creator.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftVideoCreator/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftVideoCreator' => ['SwiftVideoCreator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.swift_version = '5.0'
end
