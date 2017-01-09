#
#  Be sure to run `pod spec lint AppodealMobileAds.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AppodealMobileAds"
  s.version      = "0.3.6"
  s.summary      = "AppodealMobileAds SDK for iOS"
  s.description  = <<-DESC
                   We take pride in having an easy-to-use, flexible monetization solution that works across multiple platforms.
                   DESC

  s.homepage     = "http://appodeal.com/sdk"

  s.license      = { :type => "Copyright", :text => "Copyright 2015 Appodeal Inc. All Rights Reserved." }

  s.author             = "Appodeal Inc."
  s.social_media_url   = "http://twitter.com/appodeal"

  s.platform     = :ios, "6.0"

  s.source       = { :http => "http://s3-us-west-1.amazonaws.com/appodeal-ios/0.3.6/cocoapods/AppodealAds.framework.zip" }

  #s.preserve_paths = "Appodeal-iOS-SDK"

  # s.frameworks = "AdSupport", "AVFoundation", "AudioToolbox", "CoreTelephony", "CoreGraphics", "EventKit", "EventKitUI", "MessageUI", "StoreKit", "SystemConfiguration", "CoreLocation", "UIKit", "CoreMedia", "MediaPlayer", "QuartzCore", "CoreImage", "CoreFoundation", "Social", "WebKit", "CFNetwork" 

  s.libraries = "z", "sqlite3", "xml2.2"

  s.xcconfig = { "OTHER_LDFLAGS" => "$(inherited) -ObjC" }
  s.requires_arc = false

  s.vendored_frameworks = "AppodealAds.framework"

end
