#
# Be sure to run `pod lib lint LvJing.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LvJing'
  s.version          = '0.1'
  s.summary          = 'Filter kernel based on Metal.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LvJing is a minimum graphic filter kernel based on Metal, it offers extensible
interface and protocol for inheritance and assembling. The architecture is
inspired by `Metal by Tutorials`(Caroline Begbie & Marius Horga, raywenderlich.com)
and famous `GPUImage`.
LvJing merely acts as a carriage of Metal Shading Codes, it's your creativity
and, behind all, mathematics that really shines.
Have fun.
                       DESC

  s.homepage         = 'https://github.com/Ke Yang/LvJing'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ke Yang' => 'ofveravi@gmail.com' }
  s.source           = { :git => 'https://github.com/keyOfVv/LvJing.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = ['5.2']
  
  s.ios.deployment_target = '9.0'
  
  s.source_files = 'LvJing/Classes/**/*'
  
  s.static_framework = true
  
  # s.resource_bundles = {
  #   'LvJing' => ['LvJing/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'MetalKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-D SDK_DEBUG'
  }
end
