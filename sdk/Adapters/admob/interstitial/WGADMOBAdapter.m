//
//  WGAdmobAdapter.m
//  WordGames
//
//  Created by Dmitry B on 02.03.16.
//
//
#import "WGADMOBAdapter.h"

#ifdef ADMOB_NO_AVAILABLE

@implementation WGADMOBAdapter
@end
#endif

#ifdef ADMOB_AVAILABLE

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface WGADMOBAdapter () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation WGADMOBAdapter

- (NSString*) getName { return @"admob"; }

- (void) initAd:(NSDictionary*)paramDict {
    NSString* appID = paramDict[@"admob_inter_id"];
    //NSLog(@"admob inter id: %@", appID);
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:appID];
    self.interstitial.delegate = self;
    
    GADRequest* request = [GADRequest request];
    /*
    CLLocation *location = [[[InstanceProvider sharedProvider] sharedAODGeolocationProvider] lastKnownLocation];
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }
    */
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
        [self.delegate onFailedToLoad:[self getName]];
    }
}

#pragma mark - Admob Delegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitial adapter class name: %@", ad.adNetworkClassName);
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    //self.londLoadAdCounter = 0;
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    if ([self.delegate respondsToSelector:@selector(onClicked:)]) {
        [self.delegate onClicked:[self getName]];
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
}
@end
#endif


