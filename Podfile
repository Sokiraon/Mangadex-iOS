platform :ios, '10.0'

target "Mangadex" do
  platform :ios, '11.0'
  
  use_frameworks!
  
  pod 'MaterialComponents'
  pod 'SnapKit', '~> 5.0.1'
  pod 'Just'
  pod 'SwiftyJSON', '~> 5.0.1'
  pod 'Tabman'
  pod 'XLPagerTabStrip', '~> 9.0'
  pod 'ProgressHUD'
  pod 'Kingfisher', '~> 6.3.0'
  pod 'YYModel'
  pod 'Localize-Swift', '~> 3.2'
  pod 'Loaf'
  pod "AlignedCollectionViewFlowLayout"
  pod 'SkeletonView'
  pod 'Segmentio'
  pod 'Pageboy', '~> 3.6.2'
  pod 'SwiftEventBus', :tag => '5.1.0', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
  pod 'SwiftTheme'
  pod 'Eureka'
  pod 'SwiftEntryKit', '2.0.0'
  pod 'FlagKit'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
