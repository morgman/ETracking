source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

target 'ETDataCollection' do
    use_frameworks!

# Third-party SDKs
#    pod 'Alamofire'              #,'~> 3.5'
#    pod 'AlamofireImage'         #,'~> 2.5'
    pod 'CocoaLumberjack/Swift'   ,'3.1.0'
#    pod 'SwiftyJSON'             #,'2.4.0'
#    pod 'CocoaAsyncSocket'

# Internal SDKs
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
#            config.build_settings['SWIFT_VERSION'] = '3'
#            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end

