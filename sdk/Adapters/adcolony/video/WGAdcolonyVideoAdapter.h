//
//  WGAdcolonyVideoAdapter.h
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#import "WGAdapterProtocol.h"

@interface WGAdcolonyVideoAdapter : NSObject <WGAdapterProtocol>

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate;

@end
