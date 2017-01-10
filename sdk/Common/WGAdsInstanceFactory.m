//
//  WGAdsInstanceFactory.m
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import "WGAdConstants.h"
#import "WGAdsInstanceFactory.h"
#import "WGTimer.h"
#import "WGConfigLoader.h"
#import "WGAdAgent.h"
#import "WGLogger.h"
/*
#import "WGAdmobAdapter.h"
#import "WGUnityAdapter.h"
#import "WGAdcolonyVideoAdapter.h"
#import "WGChartboostAdapter.h"
#import "WGAdmobRewardedAdapter.h"
#import "WGAppLovinRewardAdapter.h"
 */
#import "WGInterstitialCustomEvent.h"

@implementation WGAdsInstanceFactory

+ (instancetype)sharedInstance {
    static WGAdsInstanceFactory* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] initUniqueInstance];
    });
    return _instance;
}

- (instancetype) initUniqueInstance {
    return [super init];
}

#pragma mark - For Timers
- (WGTimer*)buildTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats {
    return [WGTimer timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
}

- (WGConfigLoader*) createConfigLoader:(id<WGConfigLoaderDelegate>)delegate {
    return [WGConfigLoader initWithDelegate:delegate];
}

- (WGAdAgent*) createAdAgent:(id<WGAdAgentDelegate>)agentDelegate {
    return [[WGAdAgent alloc] initAgentWithDelegate:agentDelegate];
}

- (NSMutableDictionary*) createInterstitialAdapters:(id<WGAdapterDelegate>)delegate adnames:(NSArray*)adapterNames {
    //NSArray* adapterNames = @[
    //                          @"WGAdmobAdapter"
    //                          ,@"WGChartboostAdapter"
    //                          ];
    NSMutableDictionary* adapters = [NSMutableDictionary dictionary];
    for (NSString* adname in adapterNames) {
        NSString* className = [self createAdapterClassName:adname];
        Class customClass = NSClassFromString(className);
        if (!customClass) {
            AODLOG_DEBUG(@"Not found class %@", className);
            continue;
        } else {
            AODLOG_DEBUG(@"inter %@ created", className);
        }
        WGInterstitialCustomEvent *customEvent = [[customClass alloc] init];
        customEvent.delegate = delegate;
        [adapters setObject:customEvent forKey:[customEvent getName]];
    }
    return adapters;
    
    //return [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            //[WGAdmobAdapter sharedInstance:delegate], [[WGAdmobAdapter sharedInstance:delegate] getName],
            //*[self isInterAggregatorOn] ? [NSNull null] : */[WGChartboostAdapter sharedInstance:delegate], [[WGChartboostAdapter sharedInstance:delegate] getName],
            //nil];
}

- (NSMutableDictionary*) createVideoAdapters:(id<WGAdapterDelegate>)delegate adnames:(NSArray*)adapterNames {
    //NSArray* adapterNames = @[@"WGUnityAdapter"
    //                          ,@"WGChartboostAdapter"
     //                         , @"WGAdcolonyVideoAdapter"
    //                          , @"WGAppLovinRewardAdapter"
    //                          ];
    NSMutableDictionary* adapters = [NSMutableDictionary dictionary];
    for (NSString* adname in adapterNames) {
        NSString* className = [self createAdapterClassName:adname];
        Class customClass = NSClassFromString(className);
        if (!customClass) {
            AODLOG_DEBUG(@"Not found class %@", className);
            continue;
        } else {
            AODLOG_DEBUG(@"video %@ created", className);
        }
        WGInterstitialCustomEvent *customEvent = [[customClass alloc] init];
        customEvent.delegate = delegate;
        [adapters setObject:customEvent forKey:[customEvent getName]];
    }
    return adapters;
    //return [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            //*[self isVideoAggregatorOn] ? [NSNull null] : */[WGUnityAdapter sharedInstance:delegate], [[WGUnityAdapter sharedInstance:delegate] getName],
            //*[self isVideoAggregatorOn] ? [NSNull null] : */[WGChartboostAdapter sharedInstance:delegate], [[WGChartboostAdapter sharedInstance:delegate] getName],
            //*[self isVideoAggregatorOn] ? [NSNull null] : */[WGAdcolonyVideoAdapter sharedInstance:delegate], [[WGAdcolonyVideoAdapter sharedInstance:delegate] getName],
            //*[self isVideoAggregatorOn] ? [NSNull null] : */[WGAppLovinRewardAdapter sharedInstance:delegate], [[WGAppLovinRewardAdapter sharedInstance:delegate] getName],
            //[WGAdmobRewardedAdapter sharedInstance:delegate], [[WGAdmobRewardedAdapter sharedInstance:delegate] getName],
            //nil];
}

- (BOOL) isVideoAggregatorOn {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:PKEY_VIDEO_ADMOB_AGGR];
    if (value == 1) {
        return YES;
    }
    return NO;
}

- (BOOL) isInterAggregatorOn {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:PKEY_INTERS_ADMOB_AGGR];
    if (value == 1) {
        return YES;
    }
    return NO;
}

- (NSString*) createAdapterClassName:(NSString*)adname {
    NSString* result = [adname stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSString* className = [NSString stringWithFormat:@"WG%@Adapter", [result uppercaseString]];
    return className;
}

@end
