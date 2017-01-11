//
//  WGUnityAdapter.h
//  WordGames
//
//  Created by Dmitry B on 09.03.16.
//
//

#if defined(__has_include) && __has_include(<UnityAds/UnityAds.h>)
    #define UNITY_AVAILABLE
#else
    #define UNITY_NO_AVAILABLE
#endif

#import <AdManager/WGAdsManager.h>

@interface WGUNITYADSAdapter : WGInterstitialCustomEvent

@end
