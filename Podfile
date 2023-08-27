# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MMM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MMM
  pod 'SnapKit', '~> 5.6.0'
  pod 'Then'
  pod 'SwiftKeychainWrapper'
  pod 'FSCalendar'
  pod 'Kingfisher', '~> 7.0'
  pod 'Cosmos', '~> 23.0'
  pod 'lottie-ios'
  pod 'FirebaseAnalytics'
  pod 'Firebase/Messaging' 
  pod 'ReactorKit'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'MarqueeLabel'

  target 'MMMTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MMMUITests' do
    # Pods for testing
  end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

end
