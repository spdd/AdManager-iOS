//
//  WGAdmobRewardedAdapter.h
//  WordGames
//
//  Created by Dmitry B on 08.09.16.
//
//

#import "WGAdapterProtocol.h"

@interface WGAdmobRewardedAdapter : NSObject <WGAdapterProtocol>

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate;

@end
