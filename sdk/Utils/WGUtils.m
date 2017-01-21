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
#import "WGConfigSettings.h"

@implementation WGUtils

+ (double)getCurrentTimeMillis {
    return [[NSDate date] timeIntervalSince1970]; // * 1000;
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
    long seconds = ([[NSDate date] timeIntervalSince1970]) - savedTime;
    //int seconds = millis; //(int) (millis / 1000);
    int minutes = (int)(seconds / 60);
    int hours = minutes / 60;
    AODLOG_DEBUG(@"Loaded %d hours ago", hours);
    if (hours > [[WGConfigSettings sharedInstance] createStoreAdConfigTimeOut]) // CONFIG_STORE_TIMEOUT
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
    if  (hours > [[WGConfigSettings sharedInstance] createAntiClickerTimeOut]) // ANTICLICKER_TIMEOUT
        return YES;
    else
        return NO;
}

+ (BOOL) hasValidConfig {
    AODLOG_DEBUG(@"call hasValidConfig");
    if ([self getStringValue:@"LAST_AD_CONFIG"] == nil) {
        AODLOG_DEBUG(@"not saved LAST_AD_CONFIG");
        return NO;
    }
    NSInteger lastConfigTime = [self getIntValue:@"LAST_AD_CONFIG_TIME"];
    AODLOG_DEBUG(@"Saved time 2 : %d", lastConfigTime);
    if (lastConfigTime != 0) {
        if (![self isLoaderTimeout:lastConfigTime]) {
            AODLOG_DEBUG(@"saved config not in timeout");
            return YES;
        }
    }
    return NO;
}

+ (void) saveAdConfig:(NSString*)config {
    [self setIntValue:@"LAST_AD_CONFIG_TIME" value:[self getCurrentTimeMillis]];
    AODLOG_DEBUG(@"Saved time 1 : %d", [self getIntValue:@"LAST_AD_CONFIG_TIME"]);
    //[[NSUserDefaults standardUserDefaults] setInteger:[WGUtils getCurrentTimeMillis] forKey:@"LAST_AD_CONFIG_TIME"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    [self setStringValue:@"LAST_AD_CONFIG" value:config];
}

+ (NSString*) getAdConfig {
    return [self getStringValue:@"LAST_AD_CONFIG"];
}

#pragma mark - store data

+ (NSString*) getStringValue:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (void) setStringValue:(NSString*)key value:(NSString*)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) getIntValue:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (NSInteger) getIntValue:(NSString*)key defValue:(NSInteger)defValue {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:key] == 0) {
        return defValue;
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void) setIntValue:(NSString*)key value:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setFloatValue:(NSString*)key value:(float)value {
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (float) getFloatValue:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}

+ (void) setBoolValue:(NSString*)key value:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) getBoolValue:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

@end
