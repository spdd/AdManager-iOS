//
//  WGAppLovinAdapter.h
//  WordGames
//
//  Created by Dmitry B on 09.09.16.
//
//

#import "WGAdapterProtocol.h"

@interface WGAppLovinRewardAdapter : NSObject <WGAdapterProtocol>

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate;

@end
