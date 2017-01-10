//
//  WGBaseAdsController.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WGTypes.h"
#import "WGInterstitialCustomEvent.h"
#import "WGAdAgent.h"

@class WGAdAgent;
@class WGTimer;

@interface WGBaseAdsController : NSObject <WGPrecacheAdapterDelegate, WGAdapterDelegate, WGAdAgentDelegate>

@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSString* precacheStatus;
@property (nonatomic, strong) NSString* controllerPrefix;
@property (nonatomic) WGAdsType controllerType;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isOpened;
@property (nonatomic) BOOL isShown;
@property (nonatomic) BOOL isClicked;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isPrecacheLoaded;
@property (nonatomic) BOOL isPrecacheShown;
@property (nonatomic) BOOL isPrecacheClicked;
@property (nonatomic) BOOL isPrecacheClosed;

@property (nonatomic) double loadingStartTime;
@property (nonatomic) double loadingEndTime;

@property (nonatomic) BOOL autocache;
@property (nonatomic) BOOL hasPrecache;

@property (nonatomic) int precacheIter;
@property (nonatomic) int longLoadedAdCount;
@property (nonatomic) BOOL isServerError;
@property (nonatomic) BOOL isNoNeedLoad;
@property (nonatomic) BOOL isPreLoaderShowing;
@property (nonatomic) BOOL isNewLauch;
@property (nonatomic) BOOL isLoadedTriggerBoth;

@property (nonatomic, strong, readwrite) NSMutableDictionary* adapterInstances;
@property (nonatomic, strong, readwrite) NSArray* adapterKeys;
@property (nonatomic, strong, readwrite) WGAdAgent* adsAgent;

@property (nonatomic, strong) UIViewController* rootController;

@property (nonatomic, strong) WGTimer *refreshCachBannerTimer;
@property (nonatomic, strong) WGTimer *showPrecacheTimer;
@property (nonatomic, strong) WGTimer *precacheResetCounterTimer;
@property (nonatomic, strong) WGTimer *loadAdTimer;
@property (nonatomic, strong) WGTimer *preloaderTimer;
@property (nonatomic, strong) WGInterstitialCustomEvent *precacheAdapter;

@property (nonatomic, assign, readwrite) BOOL isPrecache;

- (void) show:(UIViewController*)rootController;
- (void) show:(UIViewController*)rootController adName:(NSString*)adName;
- (void) showAd:(UIViewController*)rootController adName:(NSString*)adName;
- (void) showAd:(UIViewController *)rootController;
- (void) cache;
- (void) loadAd;
- (void) loadPrecache;
- (BOOL) isAdLoaded;
- (BOOL) isOpened;
- (void) loadConfig;

- (void) setupAdapters:(NSArray*)adnames;
- (void) setTesting:(BOOL)isTesting;
- (void) disabledNetwork:(NSString*)network;
- (void) setAutoCache:(BOOL)autoCache;
- (BOOL) adNetworkIsAvailable:(NSString*)adName;
- (void) evokeFailedToLoadAd:(WGInterstitialCustomEvent*)adapter;
- (int)  getTimeIntervalForLoadSheduler;
- (void) scheduleFailedToLoadAd;

- (void) onStart;
- (void) onStop;
- (void) onDestroy;
- (void) onPause;
- (void) onResume;

- (void) logger:(WGAdsType)type message:(NSString*)msg;

@end
