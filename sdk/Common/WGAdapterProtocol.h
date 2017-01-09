//
//  WGAdapterProtocol.h
//  WordGames
//
//  Created by Dmitry B on 01.03.16.
//
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


@protocol WGAdapterProtocol <NSObject>

@required
- (NSString*) getName;
- (void) initAd:(NSDictionary*)paramDict;
- (BOOL) isAvailable;
- (BOOL) isCached;
- (BOOL) isAutoLoadingVideo;
- (void) showInterstitial:(UIViewController*)rootController;
@optional
- (void) showVideo:(UIViewController*)rootController;

- (void) onStart;
- (void) onStop;
- (void) onDestroy;
- (void) onPause;
- (void) onResume;
- (BOOL) isNativeSDK;

@end
