# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Weather' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Weather
  pod 'NVActivityIndicatorView'
  pod 'Alamofire'
  pod 'AlamofireNetworkActivityLogger'
  pod 'IQKeyboardManagerSwift'
  pod 'ActiveLabel'
  pod 'GoogleMaps'
  pod 'Firebase/Core'
  pod 'Firebase/RemoteConfig'
  pod 'lottie-ios'
  pod 'Google-Mobile-Ads-SDK'
  pod 'RxSwift'
  pod 'RxCocoa'
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  
end
