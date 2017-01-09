platform :ios, '8.0'
project 'AdManager.xcodeproj'
use_frameworks!

def myPods
	pod 'Firebase/Core'
	pod 'Firebase/AdMob'
	pod 'Firebase/Messaging'
	pod 'Firebase/RemoteConfig'
	pod 'ChartboostSDK',            :podspec => 'https://github.com/appodeal/CocoaPods/raw/master/ChartboostSDK/6.5.2/ChartboostSDK.podspec.json'
	pod 'UnityAds',                 :podspec => 'https://github.com/appodeal/CocoaPods/raw/master/UnityAds/2.0.5/UnityAds.podspec.json'
	pod 'AppLovin',                 :podspec => 'https://github.com/appodeal/CocoaPods/raw/master/AppLovin/3.4.3/AppLovin.podspec.json'
	pod 'AdColony', 		:podspec => 'https://github.com/appodeal/CocoaPods/raw/master/AdColony/2.6.2/AdColony.podspec.json'
end

target 'AdManager' do
    myPods
end