platform :ios, '17.0'

target "Mangadex" do
  platform :ios, '17.0'
  
  use_frameworks!
  
  pod 'SnapKit', '~> 5.7.1'
  pod 'Just'
  pod 'Alamofire'
  pod 'SwiftyJSON', '~> 5.0.2'
  pod 'ProgressHUD'
  pod 'Kingfisher', '~> 8.3.1'
  pod 'YYModel'
  pod 'Localize-Swift', '~> 3.2'
  pod 'Loaf'
  pod 'SwiftTheme'
  pod 'SwiftEntryKit', '2.0.0'
  pod 'FlagKit'
  pod "PromiseKit", "~> 8"
  pod "AsyncPlus", "~> 1.1"
  pod 'MJRefresh', :git => 'https://github.com/Sokiraon/MJRefresh.git'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebasePerformance'
  pod 'TTTAttributedLabel'
  pod "MarkdownKit"
  pod 'SkeletonView'
  pod 'Tabman'
  pod "Agrume"
  pod 'Cosmos', '~> 23.0'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
