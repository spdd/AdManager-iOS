//
//  WGAdcolonyVideoAdapter.m
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#import "WGAdcolonyVideoAdapter.h"

#ifdef AC_NO_AVAILABLE

@implementation WGAdcolonyVideoAdapter
@end
#endif

#ifdef AC_AVAILABLE

#import <AdColony/AdColony.h>

@interface WGAdcolonyVideoAdapter () <AdColonyDelegate, AdColonyAdDelegate>

@property (nonatomic, strong) NSString* zoneId;
@property (nonatomic) int londLoadAdCounter;
@property (nonatomic) BOOL isVideoCached;
@property (nonatomic) BOOL videoAutoLoading;

@end

@implementation WGAdcolonyVideoAdapter

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate {
    static WGAdcolonyVideoAdapter* _instance;
    
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
    return @"adcolony";
}

- (void) initAd:(NSDictionary*)paramDict {
    @try {
        [self startAdRequests:paramDict];
        if(self.londLoadAdCounter > 0) {
            //AODLOG_VIDEO(@"show video adapter");
            if ([AdColony isVirtualCurrencyRewardAvailableForZone:self.zoneId]) {
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
        // Initialize Ads
        NSString* appId = paramDict[@"ac_appId"];
        self.zoneId = paramDict[@"ac_zoneId"];
        // Initialize AdColony only once, on initial launch
#if DEBUG
        [AdColony configureWithAppID:appId zoneIDs:@[ self.zoneId ] delegate:self logging:YES];
#endif
        [AdColony configureWithAppID:appId zoneIDs:@[ self.zoneId ] delegate:self logging:NO];
        
    });
}

- (BOOL) isAvailable {
    NSArray* classes = @[@"AdColony"];
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
    if ([AdColony isVirtualCurrencyRewardAvailableForZone:self.zoneId]) {
        self.londLoadAdCounter++;
        [AdColony playVideoAdForZone:self.zoneId withDelegate:self withV4VCPrePopup:NO andV4VCPostPopup:NO];
    } else {
        [self.delegate onFailedToLoad:[self getName]];
    }
}

#pragma mark - AdColony V4VC

// Callback activated when a V4VC currency reward succeeds or fails
// This implementation is designed for client-side virtual currency without a server
// It uses NSUserDefaults for persistent client-side storage of the currency balance
// For applications with a server, contact the server to retrieve an updated currency balance
// On success, posts an NSNotification so the rest of the app can update the UI
// On failure, posts an NSNotification so the rest of the app can disable V4VC UI elements
- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID
{
    //AODLOG_VIDEO(@"AdColony zone %@ reward %i %i %@", zoneID, success, amount, currencyName);
    
    if (success) {
        if ([self.delegate respondsToSelector:@selector(onFinished:)]) {
            [self.delegate onFinished:[self getName]];
        }
        if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
            [self.delegate onClosed:[self getName]];
        }
    } else {
        
    }
}

- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID
{
    if(available) {
        // Zone ready
        //AODLOG_VIDEO(@"AdColony Zone ready %@", zoneID);
        self.isVideoCached = YES;
        if ([self.delegate respondsToSelector:@selector(onLoaded:)]) {
            [self.delegate onLoaded:[self getName]];
        }
    } else {
        // Zone loading
        //AODLOG_VIDEO(@"AdColony Zone loading %@", zoneID);
        /*
         if ([self.delegate respondsToSelector:@selector(clipAdDidFailToLoad:error:)]) {
         [self.delegate clipAdDidFailToLoad:[self getName] error:nil];
         }
         */
    }
}

#pragma mark -
#pragma mark AdColonyAdDelegate

// Is called when AdColony has taken control of the device screen and is about to begin showing an ad
// Apps should implement app-specific code such as pausing a game and turning off app music
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID
{
    if ([self.delegate respondsToSelector:@selector(onOpened:)]) {
        [self.delegate onOpened:[self getName]];
    }
}

// Is called when AdColony has finished trying to show an ad, either successfully or unsuccessfully
// If shown == YES, an ad was displayed and apps should implement app-specific code such as unpausing a game and restarting app music
- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID
{
    if ([self.delegate respondsToSelector:@selector(onClosed:)]) {
        [self.delegate onClosed:[self getName]];
    }
    if (shown) {
        if ([self.delegate respondsToSelector:@selector(onFinished:)]) {
            [self.delegate onFinished:[self getName]];
        }
        //[audio play];
    } else {
        //AODLOG_VIDEO(@"AdColony did not play an ad for zone %@", zoneID);
        self.isVideoCached = NO;
        if ([self.delegate respondsToSelector:@selector(onFailedToLoad:)]) {
            [self.delegate onFailedToLoad:[self getName]];
        }
    }
}

@end
#endif
