//
//  WGChartboostVideoAdapter.h
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#if defined(__has_include) && __has_include(<Chartboost/Chartboost.h>)
    #define CB_AVAILABLE
#else
    #define CB_NO_AVAILABLE
#endif

#import <AdManager/WGAdsManager.h>

@interface WGCHARTBOOSTAdapter : WGInterstitialCustomEvent

@end
