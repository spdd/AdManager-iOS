//
//  WGAdmobRewardedAdapter.m
//  WordGames
//
//  Created by Dmitry B on 08.09.16.
//
//

#import "WGAdmobRewardedAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface WGAdmobRewardedAdapter () <GADRewardBasedVideoAdDelegate>

@property (nonatomic, strong) id<WGAdapterDelegate> delegate;
@property (nonatomic) int londLoadAdCounter;
@property (nonatomic) BOOL isVideoCached;
@property (nonatomic) BOOL videoAutoLoading;

@end

@implementation WGAdmobRewardedAdapter

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate {
    static WGAdmobRewardedAdapter* _instance;
    
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
    return @"admob";
}

- (void) initAd:(NSDictionary*)paramDict {
    @try {
        NSString* appId = paramDict[@"admob_reward_id"];
        //NSLog(@"admob_reward_id: %@", appId);
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:appId];
    }
    @catch (NSException *exception) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

- (void)startAdRequests:(NSDictionary*)paramDict {}

- (BOOL) isAvailable {
    NSArray* classes = @[@"GADRewardBasedVideoAd"];
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

- (void) showVideo:(UIViewController*)rootController {
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootController];
    }
}

#pragma mark - Admob Reward video deledate implementation

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    /*
    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
     reward.type,
     [reward.amount doubleValue]];
    NSLog(rewardMessage); */
    
    if ([self.delegate respondsToSelector:@selector(onFinished:)]) {
        [self.delegate onFinished:[self getName]];
    }
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    //NSLog(@"Reward based video ad is received.");
    self.isVideoCached = YES;
    if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
        [self.delegate onLoaded:[self getName]];
    }
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    //NSLog(@"Opened reward based video ad.");
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    //NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    //NSLog(@"Reward based video ad is closed.");
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    //NSLog(@"Reward based video ad will leave application.");
    if ([self.delegate respondsToSelector:@selector(onClicked:)]) {
        [self.delegate onClicked:[self getName]];
    }
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    //NSLog(@"Reward based video ad failed to load.");
    self.isVideoCached = NO;
    if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

@end
