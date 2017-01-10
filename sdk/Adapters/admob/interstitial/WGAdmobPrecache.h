//
//  WGAdmobPrecache.h
//  WordGames
//
//  Created by Dmitry B on 03.03.16.
//
//

#if defined(__has_include) && __has_include(<GoogleMobileAds/GoogleMobileAds.h>)
    #define ADMOB_AVAILABLE
#else
    #define ADMOB_NO_AVAILABLE
#endif

#import <AdManager/WGInterstitialCustomEvent.h>

@interface WGAdmobPrecache : WGInterstitialCustomEvent

@end
