//
//  WGUtils.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>

@interface WGUtils : NSObject

+ (double) getCurrentTimeMillis;
+ (BOOL)isInternetAvailable;
+ (BOOL) isLoaderTimeout:(long)savedTime;
+ (BOOL) isAdOverClickerTimeout:(long)savedTime;

@end
