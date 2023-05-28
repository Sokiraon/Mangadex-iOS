platform :ios, '15.0'

target "Mangadex" do
  platform :ios, '15.0'
  
  use_frameworks!
  
  pod 'SnapKit', '~> 5.0.1'
  pod 'Just'
  pod 'SwiftyJSON', '~> 5.0.1'
  pod 'ProgressHUD'
  pod 'Kingfisher', '~> 6.3.0'
  pod 'YYModel'
  pod 'Localize-Swift', '~> 3.2'
  pod 'Loaf'
  pod 'SwiftTheme'
  pod 'SwiftEntryKit', '2.0.0'
  pod 'FlagKit'
  pod "PromiseKit", "~> 6.17.1"
  pod 'MJRefresh', :git => 'https://github.com/Sokiraon/MJRefresh.git'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebasePerformance'
  pod 'TTTAttributedLabel'
  pod "MarkdownKit"
  pod 'SkeletonView'
  pod 'Tabman'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
