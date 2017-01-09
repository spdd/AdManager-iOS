//
//  WGAdmobPrecache.m
//  WordGames
//
//  Created by Dmitry B on 03.03.16.
//
//

#import "WGAdmobPrecache.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface WGAdmobPrecache () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, strong) id<WGPrecacheAdapterDelegate> delegate;

@end

@implementation WGAdmobPrecache

+ (instancetype)sharedInstance:(id<WGPrecacheAdapterDelegate>) delegate {
    static WGAdmobPrecache* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[super alloc] init];
        _instance.delegate = delegate;
    });
    return _instance;
}

- (NSString*) getName { return @"admob"; }

- (void) initAd:(NSDictionary*)paramDict {
    NSString* appID = paramDict[@"admob_inter_id"];
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:appID];
    self.interstitial.delegate = self;
    
    GADRequest* request = [GADRequest request];
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (!([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound)) {
        request.testDevices = @[ kGADSimulatorID ];
    }
    [self.interstitial loadRequest:request];
}

- (BOOL) isAvailable {
    NSArray* classes = @[
                         @"GADInterstitial",
                         @"GADBannerView"
                         ];
    for (NSString* cl in classes) {
        if (NSClassFromString(cl) == nil) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) isCached {
    return NO;
}

- (BOOL) isAutoLoadingVideo {
    return NO;
}

- (void) showInterstitial:(UIViewController*)rootController {
    if (self.interstitial.isReady) {
        //self.londLoadAdCounter++;
        [self.interstitial presentFromRootViewController:rootController];
    } else {
        [self.delegate onPrecacheFailedToLoad:[self getName]];
    }
}

#pragma mark - Admob Delegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if ([self.delegate respondsToSelector:@selector(onPrecacheLoaded:)]) {
        [self.delegate onPrecacheLoaded:[self getName]];
    }
}
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if ([self.delegate respondsToSelector:@selector(onPrecacheFailedToLoad:)]) {
        [self.delegate onPrecacheFailedToLoad:[self getName]];
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    //self.londLoadAdCounter = 0;
    if ([self.delegate respondsToSelector:@selector(onPrecacheOpened:)]) {
        [self.delegate onPrecacheOpened:[self getName]];
    }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    if ([self.delegate respondsToSelector:@selector(onPrecacheClicked:)]) {
        [self.delegate onPrecacheClicked:[self getName]];
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    if ([self.delegate respondsToSelector:@selector(onPrecacheClosed:)]) {
        [self.delegate onPrecacheClosed:[self getName]];
    }
}

@end
