//
//  WGAdsInstanceFactory.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

@class WGAdAgent;
@class WGTimer;
@class WGConfigLoader;
@protocol WGConfigLoaderDelegate;
@protocol WGAdAgentDelegate;
@protocol WGAdapterDelegate;

#import <Foundation/Foundation.h>

@interface WGAdsInstanceFactory : NSObject

+ (instancetype) sharedInstance;
- (WGTimer*) buildTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;
- (WGConfigLoader*) createConfigLoader:(id<WGConfigLoaderDelegate>)delegate;
- (WGAdAgent*) createAdAgent:(id<WGAdAgentDelegate>)agentDelegate;
- (NSMutableDictionary*) createInterstitialAdapters:(id<WGAdapterDelegate>)delegate;
- (NSMutableDictionary*) createVideoAdapters:(id<WGAdapterDelegate>)delegate;

@end
