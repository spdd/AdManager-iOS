//
//  WGChartboostVideoAdapter.m
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#import "WGChartboostAdapter.h"
#import <AdSupport/AdSupport.h>

#ifdef CB_NO_AVAILABLE

@implementation WGChartboostAdapter
@end
#endif

#ifdef CB_AVAILABLE


#import <Chartboost/Chartboost.h>
#import <CommonCrypto/CommonDigest.h>


@interface WGChartboostAdapter () <ChartboostDelegate>

@property (nonatomic) int londLoadAdCounter;
@property (nonatomic) BOOL isVideoCached;
@property (nonatomic) BOOL videoAutoLoading;

@end

@implementation WGChartboostAdapter

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate {
    static WGChartboostAdapter* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[super alloc] init];
        _instance.delegate = delegate;
        _instance.londLoadAdCounter = 0;
        _instance.videoAutoLoading = YES;
        _instance.isVideoCached = NO;
    });
    return _instance;
}

- (NSString*) getName {
    return @"chartboost";
}

- (void) initAd:(NSDictionary*)paramDict {
    @try {
        [self startAdRequests:paramDict];
        [Chartboost cacheInterstitial:CBLocationDefault];
        [Chartboost cacheRewardedVideo:CBLocationDefault];
        /*
        if(self.londLoadAdCounter > 0) {
            NSLog(@"show video adapter");
            if ([Chartboost hasRewardedVideo:CBLocationDefault]) {
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
         */
    }
    @catch (NSException *exception) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)startAdRequests:(NSDictionary*)paramDict {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // Initialize Unity Ads
        NSString* appId = paramDict[@"cb_appId"];
        NSString* appSign = paramDict[@"cb_appSigh"];
        [Chartboost startWithAppId:appId appSignature:appSign delegate:self];
        [Chartboost setAutoCacheAds:YES];
    });
}

- (BOOL) isAvailable {
    NSArray* classes = @[@"Chartboost"];
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
    [Chartboost showInterstitial:CBLocationDefault];
}

- (void) showVideo:(UIViewController*)rootController {
    if ([Chartboost hasRewardedVideo:CBLocationDefault]) {
        self.londLoadAdCounter++;
        [Chartboost showRewardedVideo:CBLocationDefault];
    } else {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

#pragma mark - Chartboost Video delegate implementation

// Called after clips have been successfully prefetched.
- (void)didPrefetchVideos {
    self.isVideoCached = YES;
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

// Called before a rewarded clip will be displayed on the screen.
- (BOOL)shouldDisplayRewardedVideo:(CBLocation)location {
    return YES;
}

// Called after a rewarded clip has been displayed on the screen.
- (void)didDisplayRewardedVideo:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

// Called after a rewarded clip has been loaded from the Chartboost API
// servers and cached locally.
- (void)didCacheRewardedVideo:(CBLocation)location {
    self.isVideoCached = YES;
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

// Called after a rewarded clip has attempted to load from the Chartboost API
// servers but failed.
- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error {
    self.isVideoCached = NO;
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

// Called after a rewarded clip has been dismissed.
- (void)didDismissRewardedVideo:(CBLocation)location {
    
}

// Called after a rewarded clip has been closed.
- (void)didCloseRewardedVideo:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
}

// Called after a rewarded clip has been clicked.
- (void)didClickRewardedVideo:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onClicked:)]) {
        [self.delegate onClicked:[self getName]];
    }
}

// Called after a rewarded clip has been viewed completely and user is eligible for reward.
- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward {
    if ([self.delegate respondsToSelector:@selector(onFinished:)]) {
        [self.delegate onFinished:[self getName]];
    }
}

// Implement to be notified of when a clip will be displayed on the screen for
// a given CBLocation. You can then do things like mute effects and sounds.
- (void)willDisplayVideo:(CBLocation)location {
    
}

#pragma mark - Chartboost Interstitial implementation

- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}

// Called before an interstitial will be displayed on the screen.
- (BOOL)shouldDisplayInterstitial:(CBLocation)location {
    return YES;
}

// Called after an interstitial has been displayed on the screen.
- (void)didDisplayInterstitial:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        self.londLoadAdCounter = 0;
        [self.delegate onOpened:[self getName]];
    }
}

// Called after an interstitial has attempted to load from the Chartboost API
// servers but failed.
- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error {
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

// Called after an interstitial has been dismissed.
- (void)didDismissInterstitial:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
}

// Called after an interstitial has been closed.
- (void)didCloseInterstitial:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
}

// Called after an interstitial has been clicked.
- (void)didClickInterstitial:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onClicked:)]) {
        [self.delegate onClicked:[self getName]];
    }
}

// Called after an interstitial has been loaded from the Chartboost API
// servers and cached locally.
- (void)didCacheInterstitial:(CBLocation)location {
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

@end
#endif
