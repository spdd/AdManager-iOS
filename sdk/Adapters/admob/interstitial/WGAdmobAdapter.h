//
//  WGAdmobAdapter.h
//  WordGames
//
//  Created by Dmitry B on 02.03.16.
//
//

#if defined(__has_include) && __has_include(<GoogleMobileAds/GoogleMobileAds.h>)
    #define ADMOB_AVAILABLE
#else
    #define ADMOB_NO_AVAILABLE
#endif

#import "WGAdapterProtocol.h"

@interface WGAdmobAdapter : NSObject <WGAdapterProtocol>

+ (instancetype)sharedInstance:(id<WGAdapterDelegate>) delegate;

@end
