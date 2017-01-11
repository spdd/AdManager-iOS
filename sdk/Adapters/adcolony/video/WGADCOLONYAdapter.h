//
//  WGAdcolonyVideoAdapter.h
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#if defined(__has_include) && __has_include(<AdColony/AdColony.h>)
    #define AC_AVAILABLE
#else
    #define AC_NO_AVAILABLE
#endif

#import <AdManager/WGAdsManager.h>

@interface WGADCOLONYAdapter : WGInterstitialCustomEvent

@end
