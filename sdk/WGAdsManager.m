//
//  WGAdsManager.m
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import "WGAdConstants.h"
#import "WGAdsManager.h"
#import "WGInterstitialController.h"
#import "WGVideoController.h"
#import "WGLogger.h"

@implementation WGAdsManager

+ (instancetype) sharedInstance {
    return [self initWithAutoCache:YES];
}

+ (instancetype)initWithAutoCache:(BOOL)autoCache {
    static WGAdsManager* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[super alloc] initUniqueInstance];
        [[NSUserDefaults standardUserDefaults] setBool:autoCache forKey:PKEY_AUTOCACHE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AODLOG_DEBUG(@"Initialize interstitial");
        [WGInterstitialController initialize:autoCache];
        [WGVideoController initialize:autoCache];
    });
    return _instance;
}

+ (instancetype)initWithAdsConfig:(NSString*)adsConfig autocache:(BOOL)autoCache {
    static WGAdsManager* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[super alloc] initUniqueInstance];
        [[NSUserDefaults standardUserDefaults] setBool:autoCache forKey:PKEY_AUTOCACHE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:adsConfig forKey:PKEY_GAME_ADCONFIG];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AODLOG_DEBUG(@"Initialize interstitial");
        [WGInterstitialController initialize:autoCache];
        [WGVideoController initialize:autoCache];
    });
    return _instance;
}

- (instancetype) initUniqueInstance {
    return [super init];
}

#pragma mark - interstitial section

+ (void)showInterstitial:(UIViewController*)rootController {
    [[WGInterstitialController sharedInstance] show:rootController];
}
+ (void)showInterstitial:(UIViewController*)rootController withAdName:(NSString*)adName {
    [[WGInterstitialController sharedInstance] show:rootController adName:adName];
}

+ (void)setInterstitialDelegate:(id<WGInterstitialDelegate>) interstitialDelegate {
    [[WGInterstitialController sharedInstance] setAdDelegate:interstitialDelegate];
}

+ (void)cacheInterstitial { [[WGInterstitialController sharedInstance] cache]; }

+ (void)setAutoCache:(BOOL)autoCache {
    [[WGInterstitialController sharedInstance] setAutoCache:autoCache];
}

+ (BOOL)isInterstitialLoaded { return [[WGInterstitialController sharedInstance] isAdLoaded]; }

+ (BOOL)adNetworkIsAvailable:(NSString*)adName {
    return [[WGInterstitialController sharedInstance] adNetworkIsAvailable:adName];
}

+ (void)setTesting:(BOOL)testing {
    [[WGInterstitialController sharedInstance] setTesting:testing];
}

+ (void)disableAdNetwork:(NSString*)adName {
    [[WGInterstitialController sharedInstance] disabledNetwork:adName];
}

#pragma mark - video section

+ (void)showVideo:(UIViewController*)rootController {
    [[WGVideoController sharedInstance] show:rootController];
}

+ (void)showVideo:(UIViewController*)rootController withAdName:(NSString*)adName {
    [[WGVideoController sharedInstance] show:rootController adName:adName];
}

+ (BOOL)isVideoLoaded {
    return [[WGVideoController sharedInstance] isLoaded];
}

+ (void)cacheVideo {
    [[WGVideoController sharedInstance] cache];
}

+ (void)setVideoAdDelegate:(id<WGVideoDelegate>) videoDelegate {
    [[WGVideoController sharedInstance] setAdDelegate:videoDelegate];
}

#pragma mark - banner section

+ (void)hideBanner { /** TODO **/ }
+ (void)setBannerDelegate:(id<WGBannerDelegate>) bannerDelegate { /** TODO **/ }

#pragma mark - other things

+ (void)fireEvent:(NSString*)eventName evenData:(NSDictionary*)eventData { /** TODO **/ }

@end
