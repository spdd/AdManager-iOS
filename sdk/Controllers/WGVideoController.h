//
//  WGVideoController.h
//  WordGames
//
//  Created by Dmitry B on 07.03.16.
//
//

#import "WGBaseAdsController.h"

@protocol WGVideoDelegate;

@interface WGVideoController : WGBaseAdsController

+ (instancetype) sharedInstance;
+ (instancetype) initialize:(BOOL)autoCache;
- (void) setAdDelegate:(id<WGVideoDelegate>)delegate;

@end
