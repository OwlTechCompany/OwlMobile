# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

inhibit_all_warnings!

target 'Owl' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Owl
  pod 'SwiftGen', '~> 6.0'
  pod 'SwiftLint'

end

post_install do |installer|
  # XCode 12 drop support for iOS 8, keep this until fixed in CocoaPods
  # source: https://www.jessesquires.com/blog/2020/07/20/xcode-12-drops-support-for-ios-8-fix-for-cocoapods/
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
