
Pod::Spec.new do |s|
  s.name             = 'LvJing'
  s.version          = '0.6.alpha.1'
  s.summary          = 'Filter kernel based on Metal.'

  s.description      = <<-DESC
LvJing is a minimum graphic filter kernel based on Metal, it offers extensible
interface and protocol for inheritance and assembling. The architecture is
inspired by `Metal by Tutorials`(Caroline Begbie & Marius Horga, raywenderlich.com)
and famous `GPUImage`.
LvJing merely acts as a carriage of Metal Shading Codes, it's your creativity
and, behind all, mathematics that really shines.
Have fun.
                       DESC

  s.homepage         = 'https://github.com/keyOfVv/LvJing'
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
  
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-D SDK_DEBUG'
  }
end
