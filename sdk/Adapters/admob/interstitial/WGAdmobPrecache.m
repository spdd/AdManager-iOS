//
//  WGAdmobPrecache.m
//  WordGames
//
//  Created by Dmitry B on 03.03.16.
//
//

#import "WGAdmobPrecache.h"
#ifdef ADMOB_NO_AVAILABLE

@implementation WGAdmobPrecache
@end
#endif

#ifdef ADMOB_AVAILABLE

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface WGAdmobPrecache () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation WGAdmobPrecache

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
        [self.precacheDelegate onPrecacheFailedToLoad:[self getName]];
    }
}

#pragma mark - Admob Delegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if ([self.precacheDelegate respondsToSelector:@selector(onPrecacheLoaded:)]) {
        [self.precacheDelegate onPrecacheLoaded:[self getName]];
    }
}
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if ([self.precacheDelegate respondsToSelector:@selector(onPrecacheFailedToLoad:)]) {
        [self.precacheDelegate onPrecacheFailedToLoad:[self getName]];
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    //self.londLoadAdCounter = 0;
    if ([self.precacheDelegate respondsToSelector:@selector(onPrecacheOpened:)]) {
        [self.precacheDelegate onPrecacheOpened:[self getName]];
    }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    if ([self.precacheDelegate respondsToSelector:@selector(onPrecacheClicked:)]) {
        [self.precacheDelegate onPrecacheClicked:[self getName]];
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    if ([self.precacheDelegate respondsToSelector:@selector(onPrecacheClosed:)]) {
        [self.precacheDelegate onPrecacheClosed:[self getName]];
    }
}

@end
#endif
