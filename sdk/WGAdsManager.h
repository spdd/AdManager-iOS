//
//  WGAdsManager.h
//  if3games
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WGUserAdCallbacks.h"
#import "WGInterstitialCustomEvent.h"
#import "WGConfigLoader.h"

//#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
//#error The AdsManager SDK requires a deployment target of iOS 7.0 or later.
//#endif

FOUNDATION_EXPORT const unsigned char WGAdsManagerAdsVersionString[];

/*!
 @class WGAdsManager
 
 @abstract
 Provide methods to display and control WGAdsManager many advertising types.
 
 @discussion For more information on integrating and using the WGAdsManager SDK
 please visit our help site documentation at https://github.com/spdd
 */
@interface WGAdsManager : NSObject

+ (instancetype) alloc __attribute__((unavailable("alloc not available, call initWithAppId instead")));
- (instancetype) init __attribute__((unavailable("init not available, call initWithAppId instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call initWithAppId instead")));

+ (instancetype)initWithAutoCache:(BOOL)autoCache;
+ (instancetype)initWithAdsConfig:(NSString*)adsConfig autocache:(BOOL)autoCache;

+ (void)showInterstitial:(UIViewController*)rootController;
+ (void)showInterstitial:(UIViewController*)rootController withAdName:(NSString*)adName;

+ (void)showVideo:(UIViewController*)rootController;
+ (void)showVideo:(UIViewController*)rootController withAdName:(NSString*)adName;

+ (void)setAutoCache:(BOOL)autoCache;

+ (BOOL)isInterstitialLoaded;
+ (BOOL)isVideoLoaded;

+ (void)cacheInterstitial;
+ (void)cacheVideo;

+ (void)hideBanner;

+ (void)fireEvent:(NSString*)eventName evenData:(NSDictionary*)eventData;

+ (void)setBannerDelegate:(id<WGBannerDelegate>) bannerDelegate;
+ (void)setInterstitialDelegate:(id<WGInterstitialDelegate>) interstitialDelegate;
+ (void)setVideoAdDelegate:(id<WGVideoDelegate>) videoDelegate;

+ (BOOL)adNetworkIsAvailable:(NSString*)adName;

+ (void)disableAdNetwork:(NSString*)adName;
+ (void)setTesting:(BOOL)testing;

@end
