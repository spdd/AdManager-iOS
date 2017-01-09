//
//  WGInterstitialController.h
//  WordGames
//
//  Created by Dmitry B on 01.03.16.
//
//

#import "WGBaseAdsController.h"

@protocol WGInterstitialDelegate;

@interface WGInterstitialController : WGBaseAdsController

+ (instancetype) sharedInstance;
+ (instancetype) initialize:(BOOL)autoCache;
- (void) setAdDelegate:(id<WGInterstitialDelegate>)delegate;

@end
