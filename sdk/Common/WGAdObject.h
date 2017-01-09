//
//  WGAdObject.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>

@class WGAdObject;

@protocol WGAdObjectDelegate <NSObject>

- (void)refreshAdObjects;
- (int)getAdType;
- (void)onAdFailedLoad;
- (void)onAdPrecacheFailedLoad;
- (void)onAdLoaded:(WGAdObject*)adObject;
- (void)addCachedVideo:(NSString*)adName;
- (void)removeCachedVideo:(NSString*)adName;
- (void)onDisableNetwork:(NSString*)adName;

@end

@interface WGAdObject : NSObject

- (id)initWithData:(NSDictionary*)requestData cost:(int)cost delegate:(id<WGAdObjectDelegate>)delegate;
- (void)setLoadedAd:(BOOL)loaded;
- (NSString*)getAdName;
- (void)resetAd;
- (float)getCalculatedCost;
- (int)loadsCount;
- (void)setTryLoadingCount;
- (int)getTryLoadingCount;
- (void)cacheNextVideo;
- (void)setObjectToTop;
- (void)didVideoShown:(BOOL)shown;
- (void) setClicketAd;

@property (nonatomic, strong) NSDictionary* requestData;
@property (nonatomic, readonly) BOOL isFailed;
@property (nonatomic, readonly) BOOL isVideoCached;
@property (nonatomic, readonly) double priceFloor;
@property (nonatomic, readonly) int loaderTime;
@property (nonatomic) BOOL isPrecache;

@end
