//
//  WGAppLovinAdapter.m
//  WordGames
//
//  Created by Dmitry B on 09.09.16.
//
//

#import "WGAPPLOVINAdapter.h"

#ifdef APPLOVIN_NO_AVAILABLE

@implementation WGAPPLOVINAdapter
@end
#endif

#ifdef APPLOVIN_AVAILABLE

#import "ALSdk.h"
#import "ALIncentivizedInterstitialAd.h"

@interface WGAPPLOVINAdapter () <ALAdLoadDelegate, ALAdRewardDelegate,
ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic) int londLoadAdCounter;
@property (nonatomic) BOOL isVideoCached;
@property (nonatomic) BOOL videoAutoLoading;

@end

@implementation WGAPPLOVINAdapter

- (id) init {
    self = [super init];
    if (self != nil) {
        self.londLoadAdCounter = 0;
        self.videoAutoLoading = YES;
        self.isVideoCached = NO;
    }
    return self;
}

- (NSString*) getName {
    return @"applovin";
}

- (void) initAd:(NSDictionary*)paramDict {
    @try {
        [self startAdRequests:paramDict];
        if ([[ALSdk shared] sdkKey] == nil) {
            [self.delegate onFailedToLoad:[self getName]];
        }
        [[ALIncentivizedInterstitialAd shared] setAdDisplayDelegate:self];
        [[ALIncentivizedInterstitialAd shared] setAdVideoPlaybackDelegate:self];
        
        if (![[ALIncentivizedInterstitialAd shared] isReadyForDisplay]) {
            [[ALIncentivizedInterstitialAd shared] preloadAndNotify:self];
            self.isVideoCached = YES;
        }
    }
    @catch (NSException *exception) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)startAdRequests:(NSDictionary*)paramDict {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [ALSdk initializeSdk];
    });
}

- (void) clearDelegates {
    [ALIncentivizedInterstitialAd shared].adDisplayDelegate = nil;
    [ALIncentivizedInterstitialAd shared].adVideoPlaybackDelegate = nil;
}

- (BOOL) isAvailable {
    NSArray* classes = @[@"ALIncentivizedInterstitialAd"];
    for (NSString* cl in classes) {
        if (NSClassFromString(cl) == nil) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) isCached {
    return self.isVideoCached;
}

- (BOOL) isAutoLoadingVideo {
    return YES;
}

- (void) showInterstitial:(UIViewController*)rootController {
    
}

- (void) showVideo:(UIViewController*)rootController {
    if (!self.isVideoCached) {
        [self.delegate onFailedToLoad:[self getName]];
    }
    [ALIncentivizedInterstitialAd showAndNotify: self];
}

#pragma mark - ALAdLoadDelegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    self.isVideoCached = YES;
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    self.isVideoCached = NO;
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

#pragma mark - ALAdRewardDelegate
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response {
    //NSLog(@"Reward validation successful.");
}

- (void)rewardValidationRequestForAd:(ALAd *)ad
          didExceedQuotaWithResponse:(NSDictionary *)response {
    //NSLog(@"User exceeded quota.");
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response {
    //NSLog(@"User reward rejected by AppLovin servers.")'
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode {
    //NSLog(@"User could not be validated due to network issue or closed ad early.");
}

#pragma mark - ALAdDisplayDelegate
- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(onClicked:)]) {
        [self.delegate onClicked:[self getName]];
    }
}

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
    [self clearDelegates];
}

#pragma mark - ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad {
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad
             atPlaybackPercent:(NSNumber *)percentPlayed
                  fullyWatched:(BOOL)wasFullyWatched {
    if (wasFullyWatched) {
        if ([self.delegate respondsToSelector:@selector(onFinished:)]) {
            [self.delegate onFinished:[self getName]];
        }
    }
}

@end
#endif
