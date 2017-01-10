//
//  WGUnityAdapter.m
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#import "WGUnityAdapter.h"


#ifdef UNITY_NO_AVAILABLE

@implementation WGUnityAdapter
@end

#endif

#ifdef UNITY_AVAILABLE

#import <UnityAds/UnityAds.h>

@interface WGUnityAdapter () <UnityAdsDelegate>

@property (nonatomic) int londLoadAdCounter;
@property (nonatomic) BOOL isVideoCached;
@property (nonatomic) BOOL videoAutoLoading;

@end

@implementation WGUnityAdapter

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
    return @"unity_ads";
}

- (void) initAd:(NSDictionary*)paramDict {
    @try {
        [self startAdRequests:paramDict];
        if(self.londLoadAdCounter > 0) {
            //NSLog(@"show video adapter");
            //if ([[UnityAds sharedInstance] canShow] && [[UnityAds sharedInstance] canShowAds]) {
            if ([UnityAds isReady:@"rewardedVideo"]) {
                self.isVideoCached = YES;
                if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
                    [self.delegate onLoaded:[self getName]];
                }
            } else {
                self.isVideoCached = NO;
                if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
                    [self.delegate onFailedToLoad:[self getName]];
                }
            }
        }
    }
    @catch (NSException *exception) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)startAdRequests:(NSDictionary*)paramDict {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // Initialize Unity Ads
        NSString* unityKey = paramDict[@"unity_ads_id"];
        //[[UnityAds sharedInstance] startWithGameId:unityKey];
#if DEBUG
        [UnityAds initialize:unityKey delegate:self testMode:YES];
#else
        [UnityAds initialize:unityKey delegate:self];
#endif
    });
}

- (BOOL) isAvailable {
    NSArray* classes = @[@"UnityAds"];
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

- (void) showInterstitial:(UIViewController*)rootController {}

- (void) showVideo:(UIViewController*)rootController {
    /*
    [[UnityAds sharedInstance] setViewController:rootController];
    if ([[UnityAds sharedInstance] canShow] && [[UnityAds sharedInstance] canShowAds]) {
        self.londLoadAdCounter++;
        [[UnityAds sharedInstance] show];
    } else {
        [self.delegate onFailedToLoad:[self getName]];
    }
     */
    
    if ([UnityAds isReady:@"rewardedVideo"]) {
        [UnityAds show:rootController placementId:@"rewardedVideo"];
    } else {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

/*
#pragma mark - Unity Ads Delegate implementation

- (void)unityAdsFetchCompleted {
    self.isVideoCached = YES;
    self.londLoadAdCounter++;
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

- (void)unityAdsFetchFailed {
    self.isVideoCached = NO;
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)unityAdsDidShow {
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

- (void)unityAdsWillLeaveApplication {
    if ([self.delegate respondsToSelector:@selector(onClicked:)]) {
        [self.delegate onClicked:[self getName]];
    }
}

- (void)unityAdsDidHide {
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
}

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped {
    if ([self.delegate respondsToSelector:@selector(onFinished:)] && !skipped) {
        [self.delegate onFinished:[self getName]];
    }
}

- (void)unityAdsWillHide {
    
}

- (void)unityAdsVideoStarted {
    // TODO:
}

- (void)unityAdsWillShow {
    
}
 
 */

#pragma mark - Unity Ads Delegate implementation UnityAds 2.0

- (void)unityAdsReady:(NSString *)placementId {
    self.isVideoCached = YES;
    self.londLoadAdCounter++;
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message{
    self.isVideoCached = NO;
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)unityAdsDidStart:(NSString *)placementId{
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state{
    if ([self.delegate respondsToSelector:@selector(onFinished:)] && state != kUnityAdsFinishStateSkipped) {
        [self.delegate onFinished:[self getName]];
    }
}

@end
#endif
