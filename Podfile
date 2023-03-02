platform :ios, '10.0'

target "Mangadex" do
  platform :ios, '11.0'
  
  use_frameworks!
  
  pod 'MaterialComponents/Cards'
  pod 'SnapKit', '~> 5.0.1'
  pod 'Just'
  pod 'SwiftyJSON', '~> 5.0.1'
  pod 'Tabman'
  pod 'ProgressHUD'
  pod 'Kingfisher', '~> 6.3.0'
  pod 'YYModel'
  pod 'Localize-Swift', '~> 3.2'
  pod 'Loaf'
  pod 'Pageboy', '~> 3.6.2'
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
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
