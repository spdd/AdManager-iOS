//
//  WGAdAgent.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>
#import "WGTypes.h"

@class WGAdObject;

@protocol WGAdAgentDelegate <NSObject>
@required
- (void)reCacheBanner;
@optional
- (void)loadBanner;
- (void)loadPrecacheBanner;

@end

@interface WGAdAgent : NSObject

- (id)initAgentWithDelegate:(id<WGAdAgentDelegate>)delegate;

- (void)push:(NSDictionary*)data cost:(int)cost;
- (void)pushPrecache:(NSDictionary*)data cost:(int)cost;
- (WGAdObject*)getAdObject;
- (WGAdObject*)getAdObjectWithIndex:(int)index;
- (WGAdObject*)getPriceFloorAdObject;
- (WGAdObject*)getPrecacheAdObject;
- (void)clear;
- (void)disableNetwork:(NSString*)network;
- (BOOL)isContainNetwork:(NSString*)network;
- (void)setNetworkToTop:(NSString*)adName;
- (NSString*)getCachedVideo;
- (void)serverNotResponding;

- (NSArray*)getAdsList;

@property (nonatomic, weak) id<WGAdAgentDelegate> delegate;
@property (nonatomic, readonly) int adsCount;
@property (nonatomic, readonly) int precacheCount;
@property (nonatomic, readonly) BOOL isAdsReady;
@property (nonatomic, readonly) BOOL isPrecacheReady;
@property (nonatomic, readonly) BOOL isPrecacheDisabled;
@property (nonatomic, readonly) BOOL isPrecacheTmpDisabled;
@property (nonatomic, readwrite) WGAdsType adType;

@end
