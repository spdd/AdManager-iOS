//
//  WGAdmobPrecache.h
//  WordGames
//
//  Created by Dmitry B on 03.03.16.
//
//

#import "WGAdapterProtocol.h"

@interface WGAdmobPrecache : NSObject <WGAdapterProtocol>

+ (instancetype)sharedInstance:(id<WGPrecacheAdapterDelegate>) delegate;

@end
