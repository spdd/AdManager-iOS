//
//  WGInterstitialController.m
//  WordGames
//
//  Created by Dmitry B on 01.03.16.
//
//

#import "WGInterstitialController.h"
#import "WGAdsInstanceFactory.h"
#import "WGAdConstants.h"
#import "WGUserAdCallbacks.h"
#import "WGAdmobPrecache.h"
#import "WGAdObject.h"

@interface WGInterstitialController ()

@property (nonatomic, weak) id<WGInterstitialDelegate> delegate;

@end

@implementation WGInterstitialController

#pragma mark - public methods

+ (instancetype) sharedInstance {
    static WGInterstitialController* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[super alloc] initUniqueInstance];
    });
    return _instance;
}

- (instancetype) initUniqueInstance {
    return [super init];
}

+ (instancetype) initialize:(BOOL)autoCache {
    WGInterstitialController* instance = [self sharedInstance];
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance.autocache = autoCache;
        instance.controllerType = WGAdTypeInterstitial;
        instance.controllerPrefix = @"interstitial";
        instance.adapterInstances = [[WGAdsInstanceFactory sharedInstance] createInterstitialAdapters:instance];
        
        instance.adsAgent = [[WGAdsInstanceFactory sharedInstance] createAdAgent:instance];
        instance.adsAgent.adType = WGAdTypeInterstitial;
        [instance loadConfig];
        [instance logger:instance.controllerType message: @"Initialize interstitial controller"];
    });
    return instance;
}

- (void) setAdDelegate:(id<WGInterstitialDelegate>)delegate {
    self.delegate = delegate;
}

#pragma mark - overrided from base class

- (void) cache {
    [self logger:self.controllerType message:@"Cache interstitial"];
    [super cache];
}

- (void) showAd:(UIViewController *)rootController {
    [self logger:self.controllerType message:@"Show Interstitial"];
    if (self.isLoaded) {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"show banner status: %@", self.status]];
        NSObject <WGAdapterProtocol> *adapter = [self.adapterInstances objectForKey:self.status];
        if(adapter) {
            //scheduleShowPrecacheTimer();
            [adapter showInterstitial:rootController];
        }
    } else if (self.isPrecacheLoaded && !self.adsAgent.isPrecacheTmpDisabled) {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"show precache banner status: %@", self.precacheStatus]];
        [[WGAdmobPrecache sharedInstance:self] showInterstitial:rootController];
    } else {
        if (self.adsAgent.isPrecacheReady) {
            [self loadPrecache];
        }
        if (self.adsAgent.isAdsReady) {
            [self loadAd];
        } else {
            [self loadConfig];
        }
    }
}

- (void) evokeFailedToLoadAd:(id<WGAdapterProtocol>)adapter {
    [self scheduleFailedToLoadAd];
}

- (int) getTimeIntervalForLoadSheduler {
    return INTERSTITIAL_TIMEOUT_INTERVAL;
}

#pragma mark - WGAdapterDelegate

- (void) onLoaded:(NSString*)adName {
    [super onLoaded:adName];
    if (self.delegate) {
        [self.delegate onInterstitialLoaded:adName isPrecache:NO];
    }
}

- (void) onFailedToLoad { [self onFailedToLoad:nil]; }
- (void) onFailedToLoad:(NSString*)adName {
    [super onFailedToLoad:adName];
    if (self.delegate) {
        if (self.isPrecacheLoaded)
            [self.delegate onInterstitialLoaded:adName isPrecache:YES];
        else
            [self.delegate onInterstitialFailedToLoad:adName];
    }
}

- (void) onOpened:(NSString*)adName {
    if (self.delegate && !self.isShown) {
        [self.delegate onInterstitialOpened:adName];
    }
    [super onOpened:adName];
}

- (void) onClicked:(NSString*)adName {
    if (!self.isClicked) {
        [[self.adsAgent getAdObject] setClicketAd];
        if (self.delegate) {
            [self.delegate onInterstitialClicked:adName];
        }
    }
    [super onClicked:adName];
}

- (void) onClosed:(NSString*)adName {
    if (self.delegate && !self.isClosed) {
        [self.delegate onInterstitialClosed:adName];
    }
    [super onClosed:adName];
}

#pragma mark - WGPrecacheAdapterDelegate

- (void) onPrecacheLoaded:(NSString*)adName {
    [super onPrecacheLoaded:adName];
    if (self.delegate) {
        [self.delegate onInterstitialLoaded:adName isPrecache:YES];
    }
}

- (void) onPrecacheFailedToLoad { [self onPrecacheFailedToLoad:nil]; }
- (void) onPrecacheFailedToLoad:(NSString*)adName {
    [super onPrecacheFailedToLoad:adName];
    if (self.delegate) {
        [self.delegate onInterstitialFailedToLoad:adName];
    }
}

- (void) onPrecacheOpened:(NSString*)adName {
    if (self.delegate && !self.isPrecacheShown) {
        [self.delegate onInterstitialOpened:adName];
    }
    [super onPrecacheOpened:adName];
}

- (void) onPrecacheClicked:(NSString*)adName {
    if (self.delegate && !self.isPrecacheClicked) {
        [self.delegate onInterstitialClicked:adName];
    }
    [super onPrecacheClicked:adName];
}

- (void) onPrecacheClosed:(NSString*)adName {
    if (self.delegate && !self.isPrecacheClosed) {
        [self.delegate onInterstitialClosed:adName];
    }
    [super onPrecacheClosed:adName];
}

@end
