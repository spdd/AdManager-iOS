//
//  WGUtils.m
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import "WGUtils.h"
#import "WGLogger.h"
#import "WGAdConstants.h"
#import "WGReachability.h"

@implementation WGUtils

+ (double)getCurrentTimeMillis {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

// Check for internet with Reachability
+ (BOOL)isInternetAvailable {
    WGReachability *reachability = [WGReachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL) isLoaderTimeout:(long) savedTime {
    long millis = ([[NSDate date] timeIntervalSince1970] * 1000) - savedTime;
    int seconds = (int) (millis / 1000);
    int minutes = seconds / 60;
    int hours = minutes / 60;
    AODLOG_DEBUG(@"Loaded %d hours ago", hours);
    if (hours > CONFIG_STORE_TIMEOUT)
        return YES;
    else
        return NO;
}

+ (BOOL) isAdOverClickerTimeout:(long)savedTime {
    long millis = ([[NSDate date] timeIntervalSince1970] * 1000) - savedTime;
    int seconds = (int) (millis / 1000);
    int minutes = seconds / 60;
    int hours = minutes / 60;
    AODLOG_DEBUG(@"Was clicked %d hours ago", hours);
    if  (hours > ANTICLICKER_TIMEOUT)
        return YES;
    else
        return NO;
}

@end
