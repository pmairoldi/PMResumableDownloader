#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name         = 'PMResumableDownloader'
  s.version      = '0.0.1'
  s.license      = 'MIT'
  s.summary      = 'Resumable file downloader for iOS'
  s.homepage     = 'https://github.com/petester42/PMResumableDownloader'
  s.author       = { "Pierre-Marc Airoldi" => "pierremarcairoldi@gmail.com" }
  s.source       = { :git => 'https://github.com/petester42/PMResumableDownloader.git', :tag => '0.0.1' }
  s.source_files = 'Classes/*'
  s.requires_arc = true
  s.platform     = :ios, '6.0'
  #s.ios.deployment_target = '6.0'
end