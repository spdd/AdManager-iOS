//
//  WGInterstitialCustomEvent.h
//  AdManager
//
//  Created by Dmitry B on 09.01.17.
//  Copyright © 2017 if3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WGAdapterDelegate <NSObject>

@optional
- (void) onLoaded:(NSString*)adName;
- (void) onFailedToLoad:(NSString*)adName;
- (void) onOpened:(NSString*)adName;
- (void) onClicked:(NSString*)adName;
- (void) onClosed:(NSString*)adName;
- (void) onFinished:(NSString*)adName;

@end

// Precache Delegate
@protocol WGPrecacheAdapterDelegate <NSObject>

@optional
- (void) onPrecacheLoaded:(NSString*)adName;
- (void) onPrecacheFailedToLoad:(NSString*)adName;
- (void) onPrecacheOpened:(NSString*)adName;
- (void) onPrecacheClicked:(NSString*)adName;
- (void) onPrecacheClosed:(NSString*)adName;
- (void) onPrecacheFinished:(NSString*)adName;

@end

@interface WGInterstitialCustomEvent : NSObject

- (NSString*) getName;
- (void) initAd:(NSDictionary*)paramDict;
- (BOOL) isAvailable;
- (BOOL) isCached;
- (BOOL) isAutoLoadingVideo;
- (void) showInterstitial:(UIViewController*)rootController;
- (void) showVideo:(UIViewController*)rootController;

- (void) onStart;
- (void) onStop;
- (void) onDestroy;
- (void) onPause;
- (void) onResume;
- (BOOL) isNativeSDK;

@property (nonatomic, weak) id<WGAdapterDelegate> delegate;
@property (nonatomic, weak) id<WGPrecacheAdapterDelegate> precacheDelegate;

@end
