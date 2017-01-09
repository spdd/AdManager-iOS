//
//  UserAdCallbacks.h
//  WordGames
//
//  Created by Dmitry B on 03.03.16.
//
//
#import <Foundation/Foundation.h>

@protocol WGInterstitialDelegate <NSObject>

@optional
/*!
 @abstract
 Called before an interstitial will be displayed on the screen.
 */
- (void)onInterstitialLoaded:(NSString*)adName isPrecache:(BOOL)isPrecache;
/*!
 @abstract
 Called after an interstitial has attempted to load from the if3games API
 servers but failed.
 */
- (void)onInterstitialFailedToLoad:(NSString*)adName;
/*!
 @abstract
 Called after an interstitial has been displayed on the screen.
 */
- (void)onInterstitialOpened:(NSString*)adName;
/*!
 @abstract
 Called after an interstitial has been clicked.
 */
- (void)onInterstitialClicked:(NSString*)adName;
/*!
 @abstract
 Called after an interstitial has been closed or dismissed.
 */
- (void)onInterstitialClosed:(NSString*)adName;

@end

@protocol WGBannerDelegate <NSObject>

@optional
/*!
 @abstract
 Called before an ad banner view will be displayed on the screen.
 */
- (void)onBannerLoaded:(UIView*)bannerView;
/*!
 @abstract
 Called after an ad banner view has attempted to load from the if3games API
 servers but failed.
 */
- (void)onBannerFailedToLoad;
/*!
 @abstract
 Called after an ad banner view has been displayed on the screen.
 */
- (void)onBannerShown;
/*!
 @abstract
 Called after an ad banner view has been clicked.
 */
- (void)onBannerClicked;

@end

@protocol WGVideoDelegate <NSObject>

@optional
/*!
 @abstract
 Called after a video has been loaded and cached locally.
 
 @param adName ad name
 
 @discussion Implement to be notified of when a video has been loaded and cached locally
 */
- (void)onVideoLoaded:(NSString*)adName;

/*!
 @abstract
 Called after a video has attempted to load but failed.
 
 @param adName ad name
 
 @discussion Implement to be notified of when an video has attempted to load but failed
 */
- (void)onVideoFailedToLoad:(NSString*)adName;

/*!
 @abstract
 Called after a video has been displayed on the screen.
 
 @param adName ad name
 
 @discussion Implement to be notified of when a video has
 been displayed on the screen
 */
- (void)onVideoOpened:(NSString*)adName;

/*!
 @abstract
 Called after a video has been closed.
 
 @param adName ad name
 
 @discussion Implement to be notified of when a video has been closed
 */
- (void)onVideoClosed:(NSString*)adName;

/*!
 @abstract
 Called after a video has been clicked.
 
 @param adName ad name
 
 @discussion Implement to be notified of when a video has been click.
 "Clicked" is defined as clicking the creative interface for the video.
 */
- (void)onVideoClicked:(NSString*)adName;

/*!
 @abstract
 Called after a video has been viewed completely and user is eligible for reward.
 
 @param adName ad name
 
 @discussion Implement to be notified of when a rewarded video has been viewed completely and user is eligible for reward.
 */
- (void)onVideoFinished:(NSString*)adName;

@end
