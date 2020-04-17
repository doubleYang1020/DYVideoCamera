#
# Be sure to run `pod lib lint DYVideoCamera.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DYVideoCamera'
  s.version          = '1.1.1'
  s.summary          = 'A iOS Camera FrameWork.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/doubleYang1020/DYVideoCamera'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'doubleYang1020' => 'cn_huyangyang@163.com' }
  s.source           = { :git => 'https://github.com/doubleYang1020/DYVideoCamera.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DYVideoCamera/Classes/**/*'
  
#   s.resource_bundles = {
#     'DYVideoCamera' => ['DYVideoCamera/Assets/*']
#   }
#  s.resources = 'DYVideoCamera/*.xcassets'
  
#  官方推荐使用 resource_bundles ,因为用 key-value 可以避免相同名称资源的名称冲突。
#
#  建议 bundle 的名称至少包括 pod 库的名称，避免同名冲突。
#  使用 resource 来指定资源，被指定的资源只会简单的被 copy 到目标工程中。官方认为用 resources 无法避免同名文件资源冲突，同时 Xcode 也不会对这些资源做优化。
  s.resource_bundles = {     'DYVideoCameraMedia' => ['DYVideoCamera/*.xcassets']  }
  s.ios.xcconfig = {
#      'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/../../Frameworks"',
      'OTHER_LDFLAGS' => '-ObjC'
  }

#  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Photos', 'AVFoundation', 'AssetsLibrary'
  s.ios.vendored_frameworks = 'Frameworks/KSYHTTPCache.framework'
  s.dependency 'Masonry'
  s.dependency 'GPUImage'
  s.dependency 'lottie-ios_Oc'
  s.dependency 'CocoaLumberjack'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'CocoaAsyncSocket'
end
