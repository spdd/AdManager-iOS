//
//  WGAppLovinAdapter.h
//  WordGames
//
//  Created by Dmitry B on 09.09.16.
//
//

#if defined(__has_include) && __has_include("ALSdk.h")
    #define APPLOVIN_AVAILABLE
#else
    #define APPLOVIN_NO_AVAILABLE
#endif

#import <AdManager/WGAdsManager.h>

@interface WGAPPLOVINAdapter : WGInterstitialCustomEvent

@end
