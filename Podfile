platform :ios, '10.0'

target "Mangadex" do
  platform :ios, '11.0'
  
  use_frameworks!
  
  pod 'MaterialComponents'
  pod 'SnapKit', '~> 5.0.1'
  pod 'Just'
  pod 'SwiftyJSON', '~> 5.0.1'
  pod 'Tabman', '~> 2.9'
  pod 'ProgressHUD'
  pod 'MJRefresh'
  pod 'Kingfisher', '~> 6.3.0'
  pod 'FlexLayout'
  pod 'YYModel'
  pod 'HandyJSON', '~> 5.0.2'
  pod 'Localize-Swift', '~> 3.2'
  pod 'SwiftJWT', '~> 3.6.1'
  pod 'Loaf'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
