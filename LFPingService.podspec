#
#  Be sure to run `pod spec lint LFPingService.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name     = 'LFPingService'
    s.version  = '1.0.0'
    s.license  = 'MIT'
    s.summary  = 'A delightful iOS net ping tools'
    s.homepage = 'https://github.com/LaiFengiOS/LFPingService'
    s.authors  = { 'wangxiaoxiang' => 'wangxiaoxiang@youku.com' }
    s.source   = { :git => 'https://github.com/LaiFengiOS/LFPingService.git', :tag => s.version, :submodules => true }
    s.requires_arc = true
    s.ios.deployment_target = '7.0'

    s.preserve_paths = 'releases/iOS/LFPing.framework'
    s.vendored_frameworks = 'releases/iOS/LFPing.framework'
    s.frameworks = "AVFoundation", "SystemConfiguration", "Security", "CoreTelephony", "CFNetwork"
    s.libraries = "z"
end
