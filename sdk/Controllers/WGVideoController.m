//
//  WGVideoController.m
//  WordGames
//
//  Created by Dmitry B on 07.03.16.
//
//

#import "WGVideoController.h"
#import "WGAdsInstanceFactory.h"
#import "WGAdConstants.h"
#import "WGUserAdCallbacks.h"
#import "WGAdObject.h"

@interface WGVideoController ()

@property (nonatomic, weak) id<WGVideoDelegate> delegate;

@end

@implementation WGVideoController

+ (instancetype) sharedInstance {
    static WGVideoController* _instance;
    
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
    WGVideoController* instance = [self sharedInstance];
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance.autocache = autoCache;
        instance.controllerType = WGAdTypeVideo;
        instance.controllerPrefix = @"video";
        instance.adapterInstances = [[WGAdsInstanceFactory sharedInstance] createVideoAdapters:instance];
        
        instance.adsAgent = [[WGAdsInstanceFactory sharedInstance] createAdAgent:instance];
        instance.adsAgent.adType = WGAdTypeVideo;
        [instance loadConfig];
        [instance logger:instance.controllerType message: @"Initialize video controller"];
    });
    return instance;
}

- (void) setAdDelegate:(id<WGVideoDelegate>)delegate {
    self.delegate = delegate;
}

#pragma mark - overrided from base class

- (void) cache {
    [self logger:self.controllerType message:@"Cache video"];
    [super cache];
}

- (void) showAd:(UIViewController *)rootController {
    [self logger:self.controllerType message:@"Show video"];
    [self logger:self.controllerType message:[NSString stringWithFormat:@"show video status: %@", self.status]];
    NSObject <WGAdapterProtocol> *adapter = [self.adapterInstances objectForKey:self.status];
    if (self.isLoaded) {
        if(adapter && [adapter isCached]) {
            NSLog(@"show current video adapter");
            [adapter showVideo:rootController];
        } else if ([self.adsAgent getCachedVideo]) {
            NSObject <WGAdapterProtocol> *nextAdapter = [self.adapterInstances objectForKey:[self.adsAgent getCachedVideo]];
            if (nextAdapter && [nextAdapter isCached]) {
                NSLog(@"show next video adapter");
                [nextAdapter showVideo:rootController];
            }
        }
            
    } else if (self.isPrecacheLoaded && !self.adsAgent.isPrecacheTmpDisabled) {
        [self logger:self.controllerType message:[NSString stringWithFormat:@"show precache video status: %@", self.precacheStatus]];
        // TODO: video precache
        //[[WGAdmobPrecache sharedInstance:self] showInterstitial:rootController];
    } else {
        if (self.adsAgent.isPrecacheReady) {
            //[self loadPrecache];
        }
        if (self.adsAgent.isAdsReady) {
            [self loadAd];
        } else {
            //[self loadConfig];
        }
    }
}

- (void) cacheNextAd {
    [self logger:self.controllerType message:@"Cache next ad"];
    [[self.adsAgent getAdObject] cacheNextVideo];
    [self loadAd];
}

- (void) evokeFailedToLoadAd:(id<WGAdapterProtocol>)adapter {
    if ([adapter isAutoLoadingVideo]) {
        [self scheduleFailedToLoadAd];
    }
}

- (int) getTimeIntervalForLoadSheduler {
    return [[self.adsAgent getAdObject] loaderTime];
}

#pragma mark - WGAdapterDelegate

- (void) onLoaded:(NSString*)adName {
    [super onLoaded:adName];
    if (self.delegate) {
        [self.delegate onVideoLoaded:adName];
    }
}

- (void) onFailedToLoad { [self onFailedToLoad:nil]; }
- (void) onFailedToLoad:(NSString*)adName {
    [super onFailedToLoad:adName];
    if (self.delegate) {
        [self.delegate onVideoFailedToLoad:adName];
    }
}

- (void) onOpened:(NSString*)adName {
    if (!self.isShown) {
        [[self.adsAgent getAdObject] didVideoShown:YES];
        if (self.delegate) {
            [self.delegate onVideoOpened:adName];
        }
    }
    [super onOpened:adName];
}

- (void) onClicked:(NSString*)adName {
    if (self.delegate && !self.isClicked) {
        [self.delegate onVideoClicked:adName];
    }
    [super onClicked:adName];
}

- (void) onClosed:(NSString*)adName {
    if (self.delegate && !self.isClosed) {
        [self.delegate onVideoClosed:adName];
    }
    [super onClosed:adName];
}

- (void) onFinished:(NSString*)adName {
    [super onFinished:adName];
    if (self.delegate) {
        [self.delegate onVideoFinished:adName];
    }
}

@end
