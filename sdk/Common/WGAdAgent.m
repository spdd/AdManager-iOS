//
//  WGAdAgent.m
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import "WGAdAgent.h"
#import "WGTimer.h"
#import "WGLogger.h"
#import "WGAdObject.h"
#import "WGAdConstants.h"
#import "WGUtils.h"
#import "WGAdsInstanceFactory.h"
#import <UIKit/UIKit.h>

@interface WGAdAgent () <WGAdObjectDelegate>

@property (nonatomic, strong) NSMutableArray* adsList;
@property (nonatomic, strong) NSArray* cachedAdsList;
@property (nonatomic, strong) NSMutableArray* precacheList;
@property (nonatomic, strong) NSMutableArray* disabledNetworks;
@property (nonatomic, strong) NSArray* cachedPrecacheList;
@property (nonatomic, strong) NSMutableArray* cachedVideoAds;
@property (assign) int precacheIndex;
@property (assign) int failedLoadsCounter;
@property (assign) int failedPrecacheLoadsCounter;
@property (nonatomic, readwrite) int adsCount;
@property (nonatomic, readwrite) int precacheCount;
@property (nonatomic, strong) WGTimer *precacheResetCounterTimer;
@property (nonatomic, strong) WGTimer *failedLoadsCounterTimer;
@property (nonatomic, strong) WGTimer *failedPrecacheLoadsCounterTimer;
@property (nonatomic, strong) WGTimer *serverNotRespTimer;
@property (nonatomic, readwrite) BOOL isAdsReady;
@property (nonatomic, readwrite) BOOL isPrecacheReady;
@property (nonatomic, readwrite) BOOL isRecaching;
@property (nonatomic, readwrite) BOOL isPrecacheDisabled;
@property (nonatomic, readwrite) BOOL isPrecacheTmpDisabled; // for show ad with name
@property (assign) CGSize deviceSize;

@end

@implementation WGAdAgent

- (id)initAgentWithDelegate:(id<WGAdAgentDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        self.adsList = [NSMutableArray array];
        self.precacheList = [NSMutableArray array];
        self.precacheIndex = 0;
        self.isAdsReady = NO;
        self.isPrecacheReady = NO;
        self.isRecaching = NO;
        self.isPrecacheDisabled = NO;
        self.isPrecacheTmpDisabled = NO;
        self.failedPrecacheLoadsCounter = 0;
        self.deviceSize = [[UIScreen mainScreen] bounds].size;
    }
    return self;
}

- (void)dealloc {
    [self.precacheResetCounterTimer invalidate];
    [self.failedLoadsCounterTimer invalidate];
    [self.failedPrecacheLoadsCounterTimer invalidate];
    [self.serverNotRespTimer invalidate];
    self.precacheList = nil;
    self.adsList = nil;
    self.delegate = nil;
}

#pragma mark - Public

- (void)push:(NSDictionary*)data cost:(int)cost {
    if (data[@"adname"]) {
        NSString* adName = data[@"adname"];
        long lastClickedTime = [[NSUserDefaults standardUserDefaults] integerForKey:adName];
        if (lastClickedTime > 0 && ![WGUtils isAdOverClickerTimeout:lastClickedTime])
            return;
    }
    
    
    if (self.disabledNetworks) {
        if (data[@"adname"]) {
            NSString* adName = data[@"adname"];
            for (NSString* ad in self.disabledNetworks) {
                if ([adName isEqualToString:ad]) {
                    return;
                }
            }
        }
    }
    if (self.adType == WGAdTypeBanner) {
        if (data[@"width"]) {
            int width = (int)[data[@"width"] integerValue];
            float factor = self.deviceSize.width/width;
            if(factor >= 3.0) {
                return;
            }
        }
    }
    
    WGAdObject* adObj = [[WGAdObject alloc] initWithData:data cost:cost delegate:self];
    [self.adsList addObject:adObj];
    self.isAdsReady = YES;
    self.isRecaching = NO;
    //self.failedLoadsCounter = 0;
}

- (void)pushPrecache:(NSDictionary*)data cost:(int)cost {
    if (self.disabledNetworks) {
        if (data[@"adname"]) {
            NSString* adName = data[@"adname"];
            for (NSString* ad in self.disabledNetworks) {
                if ([adName isEqualToString:ad]) {
                    return;
                }
            }
        }
    }
    WGAdObject* adObj = [[WGAdObject alloc] initWithData:data cost:cost delegate:nil];
    adObj.isPrecache = YES;
    [self.precacheList addObject:adObj];
    self.isPrecacheReady = YES;
}

- (BOOL) isPrecacheReady {
    return PRECACHE_ALLOWED == 0 ? NO : self.isPrecacheReady;
}

- (void)clear {
    self.isAdsReady = NO;
    self.isPrecacheReady = NO;
    [self save];
    [self.adsList removeAllObjects];
    [self.precacheList removeAllObjects];
}

- (void)save {
    if(self.adsList.count != 0) {
        self.cachedAdsList =  [[NSArray alloc] initWithArray:self.adsList];
        [self reset:self.cachedAdsList];
    }
    if(self.precacheList.count != 0) {
        self.cachedPrecacheList = [[NSArray alloc] initWithArray:self.precacheList];
        [self reset:self.cachedPrecacheList];
        AODLOG_DEBUG(@"precache saved");
    }
}

- (void)reset:(NSArray*)array {
    for (WGAdObject* item in array) {
        [item resetAd];
    }
    self.isPrecacheTmpDisabled = NO;
}

- (WGAdObject*)getAdObject {
    if(self.adsList.count == 0 && self.cachedAdsList.count == 0)
        return nil;
    
    WGAdObject* item = self.isAdsReady ? [self.adsList objectAtIndex:0] : [self.cachedAdsList objectAtIndex:0];
    if(self.adType == WGAdTypeBanner) {
        AODLOG_DEBUG(@"Cost Current Object: %f", [item getCalculatedCost]);
    }
    return item;
}

- (WGAdObject*)getAdObjectWithIndex:(int)index {
    WGAdObject* item = [self.adsList objectAtIndex:index];
    if(self.adType == WGAdTypeInterstitial) {
        AODLOG_DEBUG(@"Cost Selected Object: %f", [item getCalculatedCost]);
    }
    return item;
}

- (WGAdObject*)getPrecacheAdObject {
    if(self.precacheList.count == 0 && self.cachedPrecacheList.count == 0)
        return nil;
    if (self.precacheIndex < 0)
        return nil;
    
    WGAdObject* item = [self.precacheList objectAtIndex:self.precacheIndex]; //self.isPrecacheReady ? [self.precacheList objectAtIndex:self.precacheIndex] : [self.cachedPrecacheList objectAtIndex:self.precacheIndex];
    
    if (item.isFailed) {
        self.precacheIndex++;
        if(self.precacheIndex >= self.precacheList.count) {
            self.precacheIndex = -1;
            self.isPrecacheReady = NO;
            [self scheduleResetPrecacheCounter];
            return nil;
        }
    }
    return item;
}

- (WGAdObject*)getPriceFloorAdObject {
    if(self.adsList.count == 0 && self.cachedAdsList.count == 0)
        return nil;
    
    for (WGAdObject* obj in self.adsList) {
        if(obj && obj.priceFloor != -1) {
            return obj;
        }
    }
    return nil;
}

- (NSArray*)getAdsList {
    return self.adsList;
}

- (NSString*)getCachedVideo {
    return self.cachedVideoAds ? [self.cachedVideoAds objectAtIndex:0] : nil;
}

#pragma mark - Disable network

- (void)disableNetwork:(NSString*)network {
    if (self.adType == WGAdTypeInterstitial && [network isEqualToString:@"admob"]) {
        self.isPrecacheDisabled = YES;
    }
    
    [self disableAds:network disabledAds:self.adsList];
    [self disableAds:network disabledAds:self.precacheList];
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        self.disabledNetworks = [NSMutableArray array];
    });
    [self.disabledNetworks addObject:network];
    AODLOG_DEBUG(@"disabled %@", network);
}

- (void)disableAds:(NSString *)network disabledAds:(NSMutableArray*)ads {
    for (WGAdObject* obj in [[NSArray alloc] initWithArray:ads]) {
        if (obj.requestData[@"adname"]) {
            if([(NSString*)obj.requestData[@"adname"] isEqualToString:network]) {
                [ads removeObject:obj];
            }
        }
    }
}

#pragma networks info

- (BOOL)isContainNetwork:(NSString*)network {
    for (WGAdObject* obj in [[NSArray alloc] initWithArray:self.adsList]) {
        if (obj.requestData[@"adname"]) {
            if([(NSString*)obj.requestData[@"adname"] isEqualToString:network]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)setNetworkToTop:(NSString*)adName {
    self.isPrecacheTmpDisabled = YES;
    for (WGAdObject* obj in [[NSArray alloc] initWithArray:self.adsList]) {
        if (obj.requestData[@"adname"]) {
            if([(NSString*)obj.requestData[@"adname"] isEqualToString:adName]) {
                [obj setObjectToTop];
                return;
            }
        }
    }
}

#pragma mark - Load Precache timer to reset precache failed loads counter

- (void)scheduleResetPrecacheCounter {
    if(self.precacheResetCounterTimer)
        [self.precacheResetCounterTimer invalidate];
    
    NSTimeInterval timeInterval = RESET_FL_COUNTER_PRECACHE_TIMEOUT_FOR_TIMER;
    
    if (timeInterval > 0) {
        self.precacheResetCounterTimer = [[WGAdsInstanceFactory sharedInstance] buildTimerWithTimeInterval:timeInterval
                                                                                                         target:self
                                                                                                       selector:@selector(resetPrecacheCounter)
                                                                                                        repeats:NO];
        [self.precacheResetCounterTimer scheduleNow];
        AODLOG_FULL_BANNER(@"Scheduled the auto reset precache failed loades counter (timer to fire in %.1f seconds (%p)).", timeInterval, self.precacheResetCounterTimer);
    }
}

- (void)resetPrecacheCounter {
    AODLOG_FULL_BANNER(@"evoke resetPrecacheCounter from timer");
    self.precacheIndex = 0;
}

#pragma mark - Failed loads timer to reset failed loads counter

- (void)scheduleResetFailedLoadsCounter {
    if(self.failedLoadsCounterTimer)
        [self.failedLoadsCounterTimer invalidate];
    
    NSTimeInterval timeInterval = RESET_FL_COUNTER_BANNER_TIMEOUT_FOR_TIMER;
    
    if (timeInterval > 0) {
        self.failedLoadsCounterTimer = [[WGAdsInstanceFactory sharedInstance] buildTimerWithTimeInterval:timeInterval
                                                                                                       target:self
                                                                                                     selector:@selector(resetFailedCounter)
                                                                                                      repeats:NO];
        [self.failedLoadsCounterTimer scheduleNow];
        AODLOG_DEBUG(@"Scheduled the auto reset failed loads counter (timer to fire in %.1f seconds (%p)).", timeInterval, self.failedLoadsCounterTimer);
    }
}

- (void)resetFailedCounter {
    AODLOG_DEBUG(@"evoke resetFailedCounter from timer");
    self.isAdsReady = YES;
    self.failedLoadsCounter = 0;
    if ([self.delegate respondsToSelector:@selector(loadBanner)]) {
        [self.delegate loadBanner];
    }
}

#pragma mark - Failed loads timer to reset failed loads counter

- (void)scheduleResetPrecacheFailedLoadsCounter {
    if(self.failedPrecacheLoadsCounterTimer)
        [self.failedPrecacheLoadsCounterTimer invalidate];
    
    NSTimeInterval timeInterval = RESET_FL_COUNTER_BANNER_TIMEOUT_FOR_TIMER;
    
    if (timeInterval > 0) {
        self.failedPrecacheLoadsCounterTimer = [[WGAdsInstanceFactory sharedInstance] buildTimerWithTimeInterval:timeInterval
                                                                                                               target:self
                                                                                                             selector:@selector(resetPrecacheFailedCounter)
                                                                                                              repeats:NO];
        [self.failedPrecacheLoadsCounterTimer scheduleNow];
        AODLOG_DEBUG(@"Scheduled the auto reset precache failed loads counter (timer to fire in %.1f seconds (%p)).", timeInterval, self.failedPrecacheLoadsCounterTimer);
    }
}

- (void)resetPrecacheFailedCounter {
    AODLOG_DEBUG(@"evoke resetPrecacheFailedCounter from timer");
    self.isPrecacheReady = YES;
    self.failedPrecacheLoadsCounter = 0;
    if ([self.delegate respondsToSelector:@selector(loadPrecacheBanner)]) {
        [self.delegate loadPrecacheBanner];
    }
}

#pragma mark - schedule server not responsing

- (void)scheduleServerNotResponsing {
    if(self.serverNotRespTimer)
        [self.serverNotRespTimer invalidate];
    
    NSTimeInterval timeInterval = SERVER_NOT_RESPONDING_TIMEOUT;
    
    if (timeInterval > 0) {
        self.serverNotRespTimer = [[WGAdsInstanceFactory sharedInstance] buildTimerWithTimeInterval:timeInterval
                                                                                                  target:self
                                                                                                selector:@selector(resetServerNotRespTimer)
                                                                                                 repeats:NO];
        [self.serverNotRespTimer scheduleNow];
        AODLOG_DEBUG(@"Scheduled server not responsing (timer to fire in %.1f seconds (%p)).", timeInterval, self.serverNotRespTimer);
    }
}

- (void)resetServerNotRespTimer {
    AODLOG_DEBUG(@"Reset ServerNotResp Timer");
    if(self.serverNotRespTimer) {
        [self.serverNotRespTimer invalidate];
    }
    [self.delegate reCacheBanner];
}

- (void)serverNotResponding {
    [self scheduleServerNotResponsing];
}

#pragma mark - WGAdObjectDelegate

- (void)refreshAdObjects {
    [self sort:self.adsList];
    if ([[self.adsList objectAtIndex:0] getCalculatedCost] < 0.05) {
        if(!self.isRecaching) {
            if (self.delegate) {
                [self.delegate reCacheBanner];
                self.isRecaching = YES;
            }
        }
    }
}

- (int)getAdType {
    return (int)self.adType;
}

- (void)onAdFailedLoad {
    self.failedLoadsCounter++;
    
    if((self.adType == WGAdTypeBanner) && self.failedLoadsCounter >= 10) {
        self.isAdsReady = NO;
        [self scheduleResetFailedLoadsCounter];
        AODLOG_DEBUG(@"Banner Failed counter: %d", self.failedLoadsCounter);
    }
    
    if((self.adType == WGAdTypeInterstitial) && self.failedLoadsCounter >= 20) {
        self.isAdsReady = NO;
        [self scheduleResetFailedLoadsCounter];
        AODLOG_DEBUG(@"Interstitial Failed counter: %d", self.failedLoadsCounter);
    }
    
    if(self.adType == WGAdTypeVideo && self.failedLoadsCounter >= 5) {
        self.isAdsReady = NO;
        [self scheduleResetFailedLoadsCounter];
        AODLOG_DEBUG(@"Video Failed counter Video: %d", self.failedLoadsCounter);
    }
}

- (void)onAdPrecacheFailedLoad {
    self.failedPrecacheLoadsCounter++;
    if((self.adType == WGAdTypeInterstitial) && self.failedPrecacheLoadsCounter >= 15) {
        self.isPrecacheReady = NO;
        [self scheduleResetPrecacheFailedLoadsCounter];
        AODLOG_DEBUG(@"Precache Failed counter: %d", self.failedPrecacheLoadsCounter);
    }
}

- (void)onAdLoaded:(WGAdObject*)adObject {
    if (adObject.isPrecache) {
        return;
    }
    self.failedLoadsCounter = 0;
    self.isAdsReady = YES;
    [self reset:self.adsList];
}

- (void)addCachedVideo:(NSString*)adName {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        self.cachedVideoAds = [NSMutableArray array];
    });
    [self.cachedVideoAds addObject:adName];
}

- (void)removeCachedVideo:(NSString*)adName {
    for (NSString* ad in self.cachedVideoAds) {
        if ([adName isEqualToString:ad]) {
            [self.cachedVideoAds removeObject:ad];
            return;
        }
    }
}

- (void)onDisableNetwork:(NSString*)adName {
    @try {
        [self disableNetwork:adName];
        [[NSUserDefaults standardUserDefaults] setInteger:[WGUtils getCurrentTimeMillis] forKey:adName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - sort ads

- (void)sort:(NSMutableArray*)items {
    int sortedRangeEnd = 0;
    while (sortedRangeEnd < items.count) {
        int nextIndex = [self findNextIndexOfHighestFromIndex:items range:sortedRangeEnd];
        [items exchangeObjectAtIndex:sortedRangeEnd withObjectAtIndex:nextIndex];
        sortedRangeEnd++;
    }
    
#if DEBUG
    for (WGAdObject* item in items) {
        if ([item respondsToSelector:@selector(getCalculatedCost)]) {
            if(self.adType == WGAdTypeBanner) {
                AODLOG_DEBUG(@"Sorted List Banner: %@, cost: %f", [item getAdName], [item getCalculatedCost]);
            } else if (self.adType == WGAdTypeInterstitial) {
                AODLOG_DEBUG(@"Sorted List Interstitial: %@, cost: %f", [item getAdName], [item getCalculatedCost]);
            } else if (self.adType == WGAdTypeVideo) {
                AODLOG_DEBUG(@"Sorted List Video: %@, cost: %f", [item getAdName], [item getCalculatedCost]);
            }
        }
    }
#endif
}

- (int)findNextIndexOfHighestFromIndex:(NSArray*)items range:(int)sortedRangeEnd {
    WGAdObject* currentHighest = [items objectAtIndex:sortedRangeEnd];
    int currentHighestIndex = sortedRangeEnd;
    
    for (int i = sortedRangeEnd + 1; i < items.count; i++) {
        WGAdObject* next = [items objectAtIndex:i];
        if ([currentHighest getCalculatedCost] < [next getCalculatedCost]) {
            currentHighest = [items objectAtIndex:i];
            currentHighestIndex = i;
        }
    }
    return currentHighestIndex;
}

@end
