//
//  WGBaseAdsController.m
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import "WGBaseAdsController.h"
#import "WGAdsInstanceFactory.h"
#import "WGAdConstants.h"
#import "WGAdObject.h"
#import "WGLogger.h"
#import "WGUtils.h"
#import "WGConfigLoader.h"
#import "WGTimer.h"

@interface WGBaseAdsController () <WGConfigLoaderDelegate>

@end

@implementation WGBaseAdsController

- (id) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}


- (void)dealloc {
    [self.refreshCachBannerTimer invalidate];
    [self.precacheResetCounterTimer invalidate];
    [self.showPrecacheTimer invalidate];
    [self.loadAdTimer invalidate];
}

#pragma mark - leave and enter application

- (void)applicationWillEnterForeground {
    if(self.adsAgent && self.adsAgent.isAdsReady) {
        [self loadAd];
    }
    
    if (self.autocache && [self.refreshCachBannerTimer isValid]) {
        [self.refreshCachBannerTimer resume];
    }
    if ([self.loadAdTimer isValid]) {
        [self.loadAdTimer resume];
    }
}

- (void)applicationDidEnterBackground {
    [self logger:self.controllerType message:@"applicationDidEnterBackground"];
    [self pauseRefreshTimer];
}

- (void)pauseRefreshTimer {
    if ([self.refreshCachBannerTimer isValid]) {
        [self.refreshCachBannerTimer pause];
    }
    
    if ([self.loadAdTimer isValid]) {
        [self.loadAdTimer pause];
    }
}

#pragma mark - public methods

- (void) onStart {
    self.isOpened = NO;
    if (self.status) {
        WGInterstitialCustomEvent *adapter = [self.adapterInstances objectForKey:self.status];
        if (adapter) [adapter onStart];
    }
}

- (void) onStop {
    if (self.status) {
        WGInterstitialCustomEvent *adapter = [self.adapterInstances objectForKey:self.status];
        if (adapter) [adapter onStop];
    }
}

- (void) onDestroy {
    if (self.status) {
        WGInterstitialCustomEvent *adapter = [self.adapterInstances objectForKey:self.status];
        if (adapter) [adapter onDestroy];
    }
}

- (void) onPause {
    if (self.status) {
        WGInterstitialCustomEvent *adapter = [self.adapterInstances objectForKey:self.status];
        if (adapter) [adapter onPause];
    }
}

- (void) onResume {
    if (self.status) {
        WGInterstitialCustomEvent *adapter = [self.adapterInstances objectForKey:self.status];
        if (adapter) [adapter onResume];
    }
}

- (void) disabledNetwork:(NSString *)network {
    [self.adapterInstances removeObjectForKey:network];
    [self loadAd];
}

- (void) setTesting:(BOOL)isTesting { /** TODO: **/ }

- (BOOL) adNetworkIsAvailable:(NSString*)adName { return [self.adsAgent isContainNetwork:adName]; }

- (void) setAutoCache:(BOOL)autoCache {
    if (!autoCache) {
        if ([self.refreshCachBannerTimer isValid]) {
            [self.refreshCachBannerTimer pause];
        }
    } else {
        if ([self.refreshCachBannerTimer isValid]) {
            [self.refreshCachBannerTimer resume];
        }
    }
}

- (BOOL) isAdLoaded {
    return self.isLoaded;
}

- (BOOL) isOpened {
    return NO;
}

- (void) cache {
    self.isOpened = NO;
    [self loadAd];
}

- (void)show:(UIViewController*)rootController {
    [self showAd:rootController adName:nil];
}

- (void)show:(UIViewController*)rootController adName:(NSString*)adName {
    [self showAd:rootController adName:adName];
}

- (void)showAd:(UIViewController*)rootController adName:(NSString*)adName {
    if(!self.isLoaded && !self.isPrecacheLoaded && !self.isServerError && !self.isNoNeedLoad) {
        if (!self.isLoading) {
            if (self.adsAgent.isPrecacheReady) {
                [self loadPrecache];
            }
            
            if (self.adsAgent.isAdsReady) {
                [self loadAd];
            }
        }
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, PRELOADER_TIMEOUT_FOR_TIMER * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self showAd:rootController];
        });
        
    } else if(adName) {
        if (self.adsAgent.isAdsReady) {
            //Logger.logAds(controllerType, String.format("show with name: %s", adName));
            [self.adsAgent setNetworkToTop:adName];
            [self loadAd];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, PRELOADER_TIMEOUT_FOR_TIMER * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self showAd:rootController];
            });
        }
    } else {
        [self showAd:rootController];
    }
}

- (void) showAd:(UIViewController *)rootController {
    // should be overriden in subclass
}

- (void) checkAdapters {
    for (NSString* adapterName in self.adapterInstances.allKeys) {
        if (self.adapterInstances[adapterName] == [NSNull null]) {
            [self.adsAgent disableNetwork:adapterName];
        }
    }
}

- (void) checkAdList {
    for (WGAdObject* adObj in [self.adsAgent getAdsList]) {
        if ([self.adapterInstances objectForKey:[adObj getAdName]] == nil) {
            [self.adsAgent disableNetwork:[adObj getAdName]];
        }
    }
}

#pragma mark - ads loads management

- (void) cacheNextAd {
    [self logger:self.controllerType message:@"Cache next ad"];
    [self loadAd];
}

- (void) loadNextAd {
    [self logger:self.controllerType message:@"Load next ad"];
    [self loadAd];
}

- (void) loadAd {
    if (!self.adsAgent.isAdsReady)
        return;
    [self checkAdapters];
    [self checkAdList];

    self.status = [[self.adsAgent getAdObject] getAdName];
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Load Status: %@", self.status]];
    
    WGInterstitialCustomEvent *adapter = [self.adapterInstances objectForKey:self.status];
    if (adapter && [[adapter getName] isEqualToString:self.status]) {
        if ([adapter isAvailable]) {
            [self evokeFailedToLoadAd:adapter];
            [adapter initAd:[self.adsAgent getAdObject].requestData];
        } else {
            [self onFailedToLoad:[adapter getName]];
            return;
        }
    } else {
        [self onFailedToLoad];
        return;
    }
}

- (void) evokeFailedToLoadAd:(WGInterstitialCustomEvent*)adapter {}

- (void)loadPrecache {
    [self loadPrecache:0];
}

- (void)loadPrecache:(int)index {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            if (![self.adsAgent isPrecacheReady]) {
                return;
            }
            if ([self.adsAgent isPrecacheDisabled]) {
                return;
            }
            if([self.adsAgent getPrecacheAdObject] == nil) {
                [self onPrecacheFailedToLoad];
                return;
            }
            
            self.precacheStatus = [[self.adsAgent getPrecacheAdObject] getAdName];
            [self logger:self.controllerType message:[NSString stringWithFormat:@"Precache status: %@", self.precacheStatus]];
            
            Class customClass = NSClassFromString(@"WGAdmobPrecache");

            _precacheAdapter = [[customClass alloc] init];
            _precacheAdapter.precacheDelegate = self;
            
            if (_precacheAdapter && [[_precacheAdapter getName] isEqualToString:self.precacheStatus]) {
                if ([_precacheAdapter isAvailable]) {
                    [_precacheAdapter initAd:[self.adsAgent getPrecacheAdObject].requestData];
                } else {
                    [self onPrecacheFailedToLoad:[_precacheAdapter getName]];
                    return;
                }
            } else {
                [self onPrecacheFailedToLoad];
                return;
            }
        } @catch (NSException *exception) {
            [self onPrecacheFailedToLoad];
        }
    });
}

#pragma mark - loading config

- (void) loadConfig {
    self.isLoading = NO;
    self.isLoaded = NO;
    self.status = nil;
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Loading %@ config", self.controllerPrefix]];
    
    if ([WGUtils isInternetAvailable]) {
        self.isLoading = YES;
        // download config from network
        [[WGAdsInstanceFactory sharedInstance] createConfigLoader:self];
        if (self.autocache) {
            //scheduleRefreshCacheBanner();
        }
    }
}

#pragma mark - WGConfigLoaderDelegate

- (void) onConfigFailedToLoad:(int)errorCode {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Error in %@ controller with code: %d", self.controllerPrefix, errorCode]];
    [self.adsAgent serverNotResponding];
    self.isServerError = YES;
}

- (void) onConfigLoaded:(NSDictionary*)config {
    self.isServerError = NO;
    if (config) {
        //adsAgent.clear();
        @try {
            NSString* key = [NSString stringWithFormat:@"ads_%@", self.controllerPrefix];
            if (![config objectForKey:key]) {
                if(config[@"message"]) {
                    NSString* message = config[@"message"];
                    [self logger:self.controllerType message:message];
                    if ([message isEqualToString:@"Null"]) {
                        self.isNoNeedLoad = YES;
                        [self logger:self.controllerType message:@"No need load from web"];
                    }
                }
                return;
            }
            self.isNoNeedLoad = NO;
            // first precache
            NSArray* precacheArray = config[[NSString stringWithFormat:@"precache_%@", self.controllerPrefix]];
            if(precacheArray) {
                int cost = 1;
                for (NSDictionary* dict in precacheArray) {
                    [self.adsAgent pushPrecache:dict cost:cost];
                    cost++;
                }
            }
            
            if (self.adsAgent.isPrecacheReady) {
                [self loadPrecache];
            } else {
                [self logger:self.controllerType message:@"Precache is empty or new launch"];
            }
            
            // second ads
            NSArray* adsArray = config[[NSString stringWithFormat:@"ads_%@", self.controllerPrefix]];
            [self logger:self.controllerType message:[NSString stringWithFormat: @"adsArray size: %d", (int)adsArray.count]];
            if (adsArray) {
                NSMutableArray* adnames = [NSMutableArray array];
                for (NSDictionary* dict in adsArray) {
                    [adnames addObject:dict[@"adname"]];
                }
                [self setupAdapters:adnames];
            }
            
            if (adsArray) {
                int cost = 1;
                for (NSDictionary* dict in adsArray) {
                    if ([self isAdNameAvailable:dict[@"adname"]]) {
                        [self.adsAgent push:dict cost:cost];
                        cost++;
                    }
                }
            }
            
            if (self.adsAgent.isAdsReady) {
                [self loadAd];
            } else
                [self logger:self.controllerType message:@"Ads is empty"];
            
        } @catch (NSException *exception) {
            [self logger:self.controllerType message:[exception description]];
            [self onFailedToLoad];
        }
    }
}

- (BOOL) isAdNameAvailable:(NSString*)adName {
    for (NSString* ad in self.adapterKeys) {
        if ([adName isEqualToString:ad]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Shedulers implementation

- (void)scheduleRefreshCacheBanner {
    if(self.refreshCachBannerTimer)
        [self.refreshCachBannerTimer invalidate];
    
    NSTimeInterval timeInterval = CACHE_REFRESH_TIMEOUT_FOR_TIMER;
    
    if (timeInterval > 0) {
        self.refreshCachBannerTimer = [[WGAdsInstanceFactory sharedInstance] buildTimerWithTimeInterval:timeInterval
                                                                                                      target:self
                                                                                                    selector:@selector(refreshCacheBanner)
                                                                                                     repeats:NO];
        [self.refreshCachBannerTimer scheduleNow];
        NSString* msg = [NSString stringWithFormat:@"Scheduled the auto refresh CacheBanner timer to fire in %.1f seconds (%p).", timeInterval, self.refreshCachBannerTimer];
        [self logger:self.controllerType message:msg];
    }
}

- (void)refreshCacheBanner {
    [self logger:self.controllerType message:@"evoke cacheBanner from timer"];
    [self loadConfig];
}

#pragma mark - loadAd timer

- (void)scheduleFailedToLoadAd {
    if(self.loadAdTimer)
        [self.loadAdTimer invalidate];
    
    NSTimeInterval timeInterval = [self getTimeIntervalForLoadSheduler];
    
    if (timeInterval > 0) {
        self.loadAdTimer = [[WGAdsInstanceFactory sharedInstance] buildTimerWithTimeInterval:timeInterval
                                                                                           target:self
                                                                                         selector:@selector(timeoutLoadAd)
                                                                                          repeats:NO];
        [self.loadAdTimer scheduleNow];
        NSString* msg = [NSString stringWithFormat:@"Scheduled the auto evoke onAdFailedLoad timer to fire in %.1f seconds (%p).", timeInterval, self.loadAdTimer];
        [self logger:self.controllerType message:msg];
    }
}

- (void)timeoutLoadAd {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Timeout Load Ad status: %@", self.status]];
    [self onFailedToLoad];
}

- (int) getTimeIntervalForLoadSheduler {
    // return specific timeot for current controller, may be ovverride
    return INTERSTITIAL_TIMEOUT_INTERVAL;
}


#pragma mark - WGAdapterDelegate

- (void) onLoaded:(NSString*)adName {
    if(self.loadAdTimer)
        [self.loadAdTimer invalidate];
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    if ([self.adsAgent getAdObject])
        [[self.adsAgent getAdObject] setLoadedAd:YES];
    self.isLoaded = YES;
    self.isLoading = NO;
    self.isClicked = NO;
    self.isClosed = NO;
    self.isShown = NO;
}

- (void) onFailedToLoad { [self onFailedToLoad:nil]; }
- (void) onFailedToLoad:(NSString*)adName {
    if(self.loadAdTimer)
        [self.loadAdTimer invalidate];
    self.isLoading = NO;
    self.isLoaded = NO;
    if (!adName) {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@", self.controllerPrefix, NSStringFromSelector(_cmd)]];
    } else {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    }
    if ([self.adsAgent getAdObject])
        [[self.adsAgent getAdObject] setLoadedAd:NO];
    if (self.adsAgent.isAdsReady) {
        [self loadNextAd];
    }
}

- (void) onOpened:(NSString*)adName {
    if (!self.isShown) {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
        self.isLoaded = NO;
        self.isShown = YES;
        self.isOpened = YES;
        // todo: track impession
        
        if(self.adsAgent.isAdsReady) {
            [self cacheNextAd];
        }
    }
}

- (void) onClicked:(NSString*)adName {
    if (!self.isClicked) {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
        // todo: track click
        self.isClicked = YES;
    }
}

- (void) onClosed:(NSString*)adName {
    if (!self.isClosed) {
        self.isClosed = YES;
        self.isOpened = NO;
        [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    }
}

- (void) onFinished:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
}

#pragma mark - WGPrecacheAdapterDelegate

- (void) onPrecacheLoaded:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    
    if ([self.adsAgent getPrecacheAdObject])
        [[self.adsAgent getPrecacheAdObject] setLoadedAd:YES];
    self.isLoading = YES;
    self.isPrecacheLoaded = YES;
    self.isPrecacheShown = NO;
    self.isPrecacheClicked = NO;
    self.isPrecacheClosed = NO;
}

- (void) onPrecacheFailedToLoad { [self onPrecacheFailedToLoad:nil]; }
- (void) onPrecacheFailedToLoad:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    if ([self.adsAgent getPrecacheAdObject])
        [[self.adsAgent getPrecacheAdObject] setLoadedAd:NO];
    self.isPrecacheLoaded = NO;
    if (self.adsAgent.isPrecacheReady) {
        [self loadPrecache];
    }
}

- (void) onPrecacheOpened:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    if (!self.isPrecacheShown) {
        self.isPrecacheShown = YES;
        self.isPrecacheLoaded = NO;
        self.isOpened = YES;
        // todo: track precache impression
        if(self.adsAgent.isPrecacheReady)
           [self loadPrecache];
        
        if(self.adsAgent.isAdsReady)
            [self loadAd];
    }
}

- (void) onPrecacheClicked:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    if (!self.isPrecacheClicked) {
        self.isPrecacheClicked = YES;
        // todo: track precache click
    }
}

- (void) onPrecacheClosed:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
    if (!self.isPrecacheClosed) {
        self.isPrecacheClosed = YES;
        self.isOpened = NO;
    }
}

- (void) onPrecacheFinished:(NSString*)adName {
    [self logger:self.controllerType message:[NSString stringWithFormat:@"Type:%@ %@ %@", self.controllerPrefix, adName, NSStringFromSelector(_cmd)]];
}

#pragma AODAdAgent Delegate

- (void)reCacheBanner {
    //[self loadConfig];
}

- (void)loadBanner {
    if (self.adsAgent.isAdsReady) {
        [self loadAd];
    }
}

- (void)loadPrecacheBanner {
    if (self.adsAgent.isPrecacheReady) {
        if (self.controllerType != WGAdTypeVideo) {
            [self loadPrecache];
        }
    }
}

#pragma mark - tools

- (void) logger:(WGAdsType)type message:(NSString*)msg {
    switch (type) {
        case WGAdTypeInterstitial:
            AODLOG_FULL_BANNER(@"%@",msg);
            break;
        case WGAdTypeVideo:
            AODLOG_VIDEO(@"%@",msg);
            break;
        case WGAdTypeBanner:
            AODLOG_BANNER(@"%@",msg);
            break;
        default:
            break;
    }
}

@end
