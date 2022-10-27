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
  s.screenshots     = 'https://github.com/Slava Zubrin/WordsCloudView/Screenshots/words_cloud.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Slava Zubrin' => 'szubrin79@gmail.com' }
  s.source           = { :git => 'https://github.com/Slava Zubrin/WordsCloudView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'WordsCloudView/Classes/**/*'
  s.frameworks = 'UIKit'
end
