Pod::Spec.new do |s|
  s.name             = 'SYPreventScreenshot'
  s.version          = '0.2.0'
  s.summary          = 'A universal library for preventing screenshots and screen recordings, supporting both ImageView and Label.'

  s.description      = <<-DESC
This library supports screenshot prevention on iOS 10 and above through DRM (Digital Rights Management) and the preventsCapture feature.
                       DESC

  s.homepage         = 'https://github.com/SyNvNX/SYPreventScreenshot'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SyNvNX' => 'synvnx@outlook.com' }
  s.source           = { :git => 'https://github.com/SyNvNX/SYPreventScreenshot.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'SYPreventScreenshot/Classes/**/*'
  s.ios.library = 'z'
  s.ios.frameworks = 'CoreServices', 'CFNetwork', 'UIKit', 'AVFoundation', 'VideoToolbox'
end
