#
# Be sure to run `pod lib lint WordsCloudView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WordsCloudView'
  s.version          = '0.0.1'
  s.summary          = '`Cloud of words` view'
  s.description      = <<-DESC
  Cloud of words view. Implementation is based on the code of Christian Petah (see  https://github.com/PetahChristian/LionAndLamb ).
                    DESC
  s.homepage         = 'https://github.com/Slava Zubrin/WordsCloudView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Slava Zubrin' => 'szubrin79@gmail.com' }
  s.source           = { :git => 'https://github.com/Slava Zubrin/WordsCloudView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'WordsCloudView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WordsCloudView' => ['WordsCloudView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
