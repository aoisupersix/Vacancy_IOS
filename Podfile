# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

target ‘Vacancy’ do
    pod 'RxSwift',    '3.0.0-rc.1'
    pod 'RxCocoa',    '3.0.0-rc.1'
    pod ‘RealmSwift’
    pod ’SwiftSpinner’
    pod ‘Google-Mobile-Ads-SDK’
    pod 'DZNEmptyDataSet'
    pod 'Eureka', '~> 2.0.0-beta.1'
    pod 'Firebase'
end

target ‘VacancyTests’ do
    pod 'RxBlocking', '3.0.0-rc.1'
    pod 'RxTest',     '3.0.0-rc.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
    end
  end
end